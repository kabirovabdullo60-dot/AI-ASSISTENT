/// Shared backend config. Backend + Swagger are owned by Mehroj.
/// Ask Mehroj for the real URL and endpoints.
class ApiConstants {
  ApiConstants._();

  /// TODO: replace with the real URL from Mehroj's Swagger.
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration timeout = Duration(seconds: 20);

  /// `true` = demo data, no backend needed.
  /// Set to `false` once Mehroj's API is running.
  static const bool useMock = true;

  // TODO: confirm these paths with Mehroj's Swagger.
  static const String dashboardPath = '/dashboard';
  static const String assistantChatPath = '/assistant/chat';
}
