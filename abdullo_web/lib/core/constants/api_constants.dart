/// Shared backend config. Backend + Swagger are owned by Mehroj.
/// Ask Mehroj for the real URL and endpoints.
class ApiConstants {
  ApiConstants._();

  /// TODO: replace with the real URL from Mehroj's Swagger.
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration timeout = Duration(seconds: 20);
}
