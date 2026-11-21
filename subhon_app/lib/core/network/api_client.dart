import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

export 'api_exception.dart';

/// The one way to reach Mehroj's backend (API.md).
///
/// * Adds `Authorization: Bearer <accessToken>` to protected calls and
///   `Accept-Language` for the current app language.
/// * On `401 AUTH_TOKEN_EXPIRED` refreshes the tokens **once**, saves
///   **both** new tokens and retries the call. Calls that fail at the same
///   time share one refresh request (a refresh token works only once).
/// * Before refreshing, the saved tokens are read again: when they changed
///   meanwhile, they are used instead (an old refresh token must never be
///   sent twice — the server would end the whole session).
/// * Any other 401 on a protected call, or a refresh the server refuses
///   (401 / 403), clears the tokens and calls [onSessionExpired]. A network
///   error or a 5xx during the refresh keeps them: the person stays signed
///   in and can try again.
/// * Errors become [ApiException] with the backend `error.code`; network
///   failures become `NETWORK_ERROR`.
class ApiClient {
  ApiClient({
    required this.tokens,
    http.Client? client,
    String? baseUrl,
    this.language = _defaultLanguage,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  static String _defaultLanguage() => 'ru';

  static const _expired = 'AUTH_TOKEN_EXPIRED';
  static const refreshPath = '/api/auth/refresh';

  /// Where the access and refresh tokens are kept.
  final TokenStorage tokens;
  final http.Client _client;
  final String _baseUrl;

  /// The language of the app (`en`, `ru`, `tg`) for `Accept-Language`.
  String Function() language;

  /// Called once the session can no longer be used (the tokens are already
  /// cleared): the app returns to the login screen.
  void Function()? onSessionExpired;

  /// The refresh in progress, shared by every call that needs it.
  Future<void>? _refreshing;

  Future<dynamic> get(
    String path, {
    Map<String, Object?> query = const {},
    bool auth = true,
  }) => _send('GET', path, query: query, auth: auth);

  /// [timeout] replaces the usual one for slow calls (the AI assistant).
  Future<dynamic> post(
    String path, {
    Object? body,
    bool auth = true,
    Duration? timeout,
  }) => _send('POST', path, body: body, auth: auth, timeout: timeout);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  /// `multipart/form-data` with one file (e.g. the avatar, field `file`).
  Future<dynamic> uploadFile(
    String path, {
    required String field,
    required Uint8List bytes,
    required String filename,
    String method = 'PATCH',
  }) => _send(
    method,
    path,
    file: (field: field, bytes: bytes, filename: filename),
  );

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, Object?> query = const {},
    Object? body,
    bool auth = true,
    ({String field, Uint8List bytes, String filename})? file,
    Duration? timeout,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: {
        for (final MapEntry(:key, :value) in query.entries)
          if (value != null) key: '$value',
      }.nullIfEmpty,
    );
    var token = auth ? await tokens.readAccessToken() : null;
    final refreshBefore = auth ? await tokens.readRefreshToken() : null;
    var response = await _request(method, uri, token, body, file, timeout);
    if (auth && response.statusCode == 401) {
      final code = _errorCode(response);
      if (code == _expired) {
        final current = await tokens.readAccessToken();
        final currentRefresh = await tokens.readRefreshToken();
        if ((current != null && current != token) ||
            (currentRefresh != null && currentRefresh != refreshBefore)) {
          // Refreshed meanwhile (another call, another screen): use the new
          // tokens — calling /refresh with the old one would end the session.
          token = current;
        } else {
          await _refreshOnce();
          token = await tokens.readAccessToken();
        }
        response = await _request(method, uri, token, body, file, timeout);
      }
      if (response.statusCode == 401) {
        await _endSession();
      }
    }
    return _decode(response);
  }

  Future<http.Response> _request(
    String method,
    Uri uri,
    String? token,
    Object? body,
    ({String field, Uint8List bytes, String filename})? file, [
    Duration? timeout,
  ]) async {
    final headers = {
      'Accept': 'application/json',
      'Accept-Language': language(),
      'Authorization': ?(token == null ? null : 'Bearer $token'),
    };
    try {
      final http.BaseRequest request;
      if (file != null) {
        request = http.MultipartRequest(method, uri)
          ..files.add(
            http.MultipartFile.fromBytes(
              file.field,
              file.bytes,
              filename: file.filename,
            ),
          );
      } else {
        request = http.Request(method, uri);
        if (body != null) {
          headers['Content-Type'] = 'application/json';
          (request as http.Request).body = jsonEncode(body);
        }
      }
      request.headers.addAll(headers);
      final streamed = await _client
          .send(request)
          .timeout(timeout ?? ApiConstants.timeout);
      return await http.Response.fromStream(streamed);
    } on SocketException catch (e) {
      throw ApiException(0, ApiException.networkError, message: '$e');
    } on TimeoutException catch (e) {
      throw ApiException(0, ApiException.networkError, message: '$e');
    } on http.ClientException catch (e) {
      throw ApiException(0, ApiException.networkError, message: '$e');
    } on Exception catch (e) {
      // Anything else that stops the request from reaching the server.
      throw ApiException(0, ApiException.networkError, message: '$e');
    }
  }

  /// One refresh for every caller; both new tokens are saved.
  Future<void> _refreshOnce() =>
      _refreshing ??= _refresh().whenComplete(() => _refreshing = null);

  Future<void> _refresh() async {
    final refreshToken = await tokens.readRefreshToken();
    if (refreshToken == null) {
      await _endSession();
      throw const ApiException(401, 'AUTH_REQUIRED');
    }
    final response = await _request(
      'POST',
      Uri.parse('$_baseUrl$refreshPath'),
      null,
      {'refreshToken': refreshToken},
      null,
    );
    if (response.statusCode != 200) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        await _endSession();
      }
      _decode(response); // throws the ApiException
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await tokens.save(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }

  Future<void> _endSession() async {
    await tokens.clear();
    onSessionExpired?.call();
  }

  static String? _errorCode(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return ((data as Map<String, dynamic>)['error']
              as Map<String, dynamic>)['code']
          as String;
    } on Object {
      return null;
    }
  }

  static dynamic _decode(http.Response response) {
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (ok) {
      return response.body.isEmpty ? null : jsonDecode(response.body);
    }
    try {
      final error =
          (jsonDecode(response.body) as Map<String, dynamic>)['error']
              as Map<String, dynamic>;
      throw ApiException(
        response.statusCode,
        error['code'] as String,
        message: error['message'] as String? ?? '',
        details: [
          for (final d in error['details'] as List<dynamic>? ?? const [])
            d as Map<String, dynamic>,
        ],
        meta: error['meta'] as Map<String, dynamic>? ?? const {},
      );
    } on ApiException {
      rethrow;
    } on Object {
      throw ApiException(response.statusCode, ApiException.unknownError);
    }
  }
}

extension on Map<String, String> {
  Map<String, String>? get nullIfEmpty => isEmpty ? null : this;
}
