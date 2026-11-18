/// Backend config. Backend + Swagger are owned by Mehroj (API.md).
class ApiConstants {
  ApiConstants._();

  /// Mehroj's live backend (Swagger: `$baseUrl/docs`).
  static const String baseUrl =
      'https://api-production-86caefb2.up.railway.app';
  static const Duration timeout = Duration(seconds: 20);

  /// Lists: page size (the API allows at most 100).
  static const int pageSize = 20;
}
