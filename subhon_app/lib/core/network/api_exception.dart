/// A failed API call. [code] is the backend `error.code` (API.md), or
/// `NETWORK_ERROR` when the server could not be reached. Screens show a
/// translated text for [code], never [message].
class ApiException implements Exception {
  const ApiException(
    this.statusCode,
    this.code, {
    this.message = '',
    this.details = const [],
  });

  /// The server could not be reached (no connection, timeout).
  static const networkError = 'NETWORK_ERROR';

  /// The response was not in the documented error format.
  static const unknownError = 'UNKNOWN_ERROR';

  /// HTTP status; `0` for [networkError].
  final int statusCode;
  final String code;

  /// The backend's own text — for logs only, not for users.
  final String message;

  /// `422 VALIDATION_ERROR`: one entry per problem (`location`, `field`,
  /// `code`, `message`).
  final List<Map<String, dynamic>> details;

  @override
  String toString() => 'ApiException($statusCode, $code)';
}
