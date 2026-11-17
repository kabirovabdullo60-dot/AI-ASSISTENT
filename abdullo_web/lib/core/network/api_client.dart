import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Thin HTTP wrapper. Endpoints and payloads must follow Mehroj's Swagger contract.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  /// Set after login once the backend has auth.
  String? token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Uri _uri(String path, Map<String, String>? query) {
    final uri = Uri.parse('$_baseUrl$path');
    return query == null || query.isEmpty ? uri : uri.replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final res = await _client.get(_uri(path, query), headers: _headers).timeout(ApiConstants.timeout);
    return _handle(res);
  }

  Future<dynamic> post(String path, [Object? body]) async {
    final res = await _client
        .post(_uri(path, null), headers: _headers, body: body == null ? null : jsonEncode(body))
        .timeout(ApiConstants.timeout);
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    final data = res.body.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(res.statusCode, res.body);
  }
}
