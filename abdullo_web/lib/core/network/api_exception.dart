import 'dart:convert';

/// Error from the backend: `{"error": {"code": "...", "message": "...", "details": [...]}}`.
/// Views switch on [code] (stable) and show their own translated text.
class ApiException implements Exception {
  ApiException(this.statusCode, this.code, this.message, {this.details = const []});

  factory ApiException.fromBody(int statusCode, String body) {
    try {
      final json = jsonDecode(body);
      final err = json is Map ? json['error'] : null;
      if (err is Map) {
        return ApiException(
          statusCode,
          '${err['code'] ?? 'HTTP_$statusCode'}',
          '${err['message'] ?? ''}',
          details: [
            for (final d in (err['details'] as List? ?? const []))
              if (d is Map) Map<String, dynamic>.from(d),
          ],
        );
      }
    } catch (_) {}
    return ApiException(statusCode, 'HTTP_$statusCode', body);
  }

  /// No connection / timeout.
  factory ApiException.network(Object error) => ApiException(0, 'NETWORK_ERROR', '$error');

  final int statusCode;
  final String code;
  final String message;

  /// Validation problems: `{location, field, code, message}`.
  final List<Map<String, dynamic>> details;

  /// Field names with validation errors, e.g. `{'email', 'amount'}`.
  Set<String> get invalidFields => {for (final d in details) '${d['field'] ?? ''}'};

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
