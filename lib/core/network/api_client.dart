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

/// Thin HTTP wrapper shared by web and app services.
/// Endpoints and payloads must follow Mehroj's Swagger contract.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {String? token}) async {
    final res = await _client
        .get(Uri.parse('$_baseUrl$path'), headers: _headers(token))
        .timeout(ApiConstants.timeout);
    return _handle(res);
  }

  Future<dynamic> post(String path, Object? body, {String? token}) async {
    final res = await _client
        .post(Uri.parse('$_baseUrl$path'),
            headers: _headers(token), body: jsonEncode(body))
        .timeout(ApiConstants.timeout);
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    final data = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(res.statusCode, res.body);
  }
}
