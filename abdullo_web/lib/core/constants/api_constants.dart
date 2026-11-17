/// Backend config. Backend + Swagger are owned by Mehroj.
///
/// When Mehroj sends the endpoints:
/// 1. put the server address in [baseUrl],
/// 2. fix the paths below to match his Swagger,
/// 3. set [useMock] to `false`.
/// Nothing else in the app has to change.
class ApiConstants {
  ApiConstants._();

  /// TODO: real URL from Mehroj's Swagger.
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const Duration timeout = Duration(seconds: 20);

  /// `true` = demo data, no backend needed.
  static const bool useMock = true;

  // ---- Endpoints (TODO: confirm with Mehroj's Swagger) ----
  static const String me = '/auth/me'; // GET  → current user
  static const String overview = '/dashboard/overview'; // GET  ?storeId= → KPIs + daily revenue
  static const String activity = '/activity'; // GET  ?limit=   → recent business activity
  static const String stores = '/stores'; // GET  → all stores
  static const String sales = '/sales'; // GET list, POST {storeId, amount, method}
  static const String employees = '/employees'; // GET  → staff
  static const String payroll = '/payroll'; // GET  → salaries for the current cycle
  static String payrollPay(String id) => '/payroll/$id/pay'; // POST → mark one salary paid
  static const String assistantChat = '/assistant/chat'; // POST {messages: [...]} → reply

  /// Method, path, purpose — shown on the Settings page so the team sees the contract.
  static const List<(String, String, String)> endpointList = [
    ('GET', me, 'Current user'),
    ('GET', '$overview?storeId=', 'KPIs + daily revenue'),
    ('GET', '$activity?limit=', 'Recent business activity'),
    ('GET', stores, 'Stores'),
    ('GET', sales, 'Sales list'),
    ('POST', sales, 'Record a sale'),
    ('GET', employees, 'Employees'),
    ('GET', payroll, 'Salaries this cycle'),
    ('POST', '/payroll/{id}/pay', 'Pay one salary'),
    ('POST', assistantChat, 'AI assistant reply'),
  ];

  /// Shown in the dashboard footer.
  static const List<String> mainEndpoints = [stores, sales, payroll];
}
