import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'api_exception.dart';
import 'token_storage.dart';

export 'api_exception.dart';

/// HTTP client for Mehroj's API.
/// * adds `Authorization: Bearer <accessToken>`
/// * on `401 AUTH_TOKEN_EXPIRED` refreshes the tokens once and retries
/// * if the session can't be refreshed, calls [onSessionExpired] (→ login screen)
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl, TokenStorage? tokens})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConstants.baseUrl,
      tokens = tokens ?? TokenStorage();

  final http.Client _client;
  final String _baseUrl;
  final TokenStorage tokens;

  /// Language for backend messages ('en' / 'ru' / 'tg').
  String language = 'en';

  /// Called when the refresh token is no longer valid.
  void Function()? onSessionExpired;

  Future<bool>? _refreshing;

  Uri _uri(String path, Map<String, Object?>? query) {
    final uri = Uri.parse('$_baseUrl$path');
    final q = <String, String>{
      for (final e in (query ?? const {}).entries)
        if (e.value != null && '${e.value}'.isNotEmpty) e.key: '${e.value}',
    };
    return q.isEmpty ? uri : uri.replace(queryParameters: q);
  }

  Future<dynamic> get(String path, {Map<String, Object?>? query, bool auth = true}) =>
      _send('GET', path, query: query, auth: auth);

  /// [timeout] overrides [ApiConstants.timeout] (e.g. the AI assistant can take up to ~60 s).
  Future<dynamic> post(String path, [Object? body, bool auth = true, Duration? timeout]) =>
      _send('POST', path, body: body, auth: auth, timeout: timeout);

  Future<dynamic> put(String path, [Object? body]) => _send('PUT', path, body: body);

  Future<dynamic> patch(String path, [Object? body]) => _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  /// multipart/form-data upload (avatar).
  Future<dynamic> upload(String path, {required String field, required List<int> bytes, required String filename}) =>
      _guard(() async {
        final req = http.MultipartRequest('PATCH', _uri(path, null))
          ..headers.addAll(_headers(true, json: false))
          ..files.add(http.MultipartFile.fromBytes(field, bytes, filename: filename));
        return http.Response.fromStream(await _client.send(req).timeout(ApiConstants.timeout));
      }, auth: true);

  Map<String, String> _headers(bool auth, {bool json = true}) => {
    if (json) 'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Accept-Language': language,
    if (auth && tokens.accessToken != null) 'Authorization': 'Bearer ${tokens.accessToken}',
  };

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    bool auth = true,
    bool retried = false,
    Duration? timeout,
  }) => _guard(
    () async {
      final req = http.Request(method, _uri(path, query))..headers.addAll(_headers(auth));
      if (body != null) req.body = jsonEncode(body);
      return http.Response.fromStream(await _client.send(req).timeout(timeout ?? ApiConstants.timeout));
    },
    auth: auth,
    retry: auth && !retried
        ? () => _send(method, path, query: query, body: body, retried: true, timeout: timeout)
        : null,
  );

  Future<dynamic> _guard(
    Future<http.Response> Function() call, {
    required bool auth,
    Future<dynamic> Function()? retry,
  }) async {
    final http.Response res;
    try {
      res = await call();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException.network(e);
    }
    if (res.statusCode == 401 && auth) {
      final error = ApiException.fromBody(401, res.body);
      if (retry != null && error.code == 'AUTH_TOKEN_EXPIRED' && await refreshTokens()) return retry();
      await tokens.clear();
      onSessionExpired?.call();
      throw error;
    }
    return _handle(res);
  }

  /// POST /api/auth/refresh once (concurrent callers share the same request).
  Future<bool> refreshTokens() => _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);

  Future<bool> _doRefresh() async {
    final refresh = tokens.refreshToken;
    if (refresh == null) return false;
    try {
      final res = await _client
          .post(_uri(ApiConstants.refresh, null), headers: _headers(false), body: jsonEncode({'refreshToken': refresh}))
          .timeout(ApiConstants.timeout);
      if (res.statusCode != 200) return false;
      final json = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      await tokens.save('${json['accessToken']}', '${json['refreshToken']}');
      return true;
    } catch (_) {
      return false;
    }
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    }
    throw ApiException.fromBody(res.statusCode, utf8.decode(res.bodyBytes, allowMalformed: true));
  }
}
