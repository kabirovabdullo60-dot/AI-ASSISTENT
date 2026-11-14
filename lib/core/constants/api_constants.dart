/// Shared backend config. Backend + Swagger are owned by Mehroj.
/// Edit only on `main` (Team Lead).
class ApiConstants {
  ApiConstants._();

  /// TODO: replace with the real URL from Mehroj's Swagger.
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration timeout = Duration(seconds: 20);
}
