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
  static const String me = '/auth/me';
  static const String overview = '/dashboard/overview'; // ?storeId=
  static const String activity = '/activity'; // ?limit=

  static const String stores = '/stores'; // GET list, POST create
  static String store(String id) => '/stores/$id'; // PUT update, DELETE
  static String storeAnalytics(String id) => '/stores/$id/analytics'; // GET
  static const String storesLog = '/stores/log'; // GET operations log

  static const String sales = '/sales'; // GET list, POST create

  static const String employees = '/employees';

  static const String payroll = '/payroll'; // GET ?period=2026-11
  static String payrollPayments(String id) => '/payroll/$id/payments'; // POST {amount, method}
  static const String disbursements = '/payroll/disbursements'; // GET ?period=

  static const String assistantChat = '/assistant/chat'; // POST {messages: [...]}

  /// Method, path, purpose — shown on the Settings page so the team sees the contract.
  static const List<(String, String, String)> endpointList = [
    ('GET', me, 'Current user'),
    ('GET', '$overview?storeId=', 'Dashboard KPIs + daily revenue'),
    ('GET', '$activity?limit=', 'Recent business activity'),
    ('GET', stores, 'Stores'),
    ('POST', stores, 'Add store'),
    ('PUT', '/stores/{id}', 'Edit store'),
    ('DELETE', '/stores/{id}', 'Delete store'),
    ('GET', '/stores/{id}/analytics', 'Store analytics (7 days + POS)'),
    ('GET', storesLog, 'Store operations log'),
    ('GET', sales, 'Daily sales entries'),
    ('POST', sales, 'Record daily sales'),
    ('GET', employees, 'Employees'),
    ('GET', '$payroll?period=', 'Payroll for a month'),
    ('POST', '/payroll/{id}/payments', 'Record salary payment'),
    ('GET', '$disbursements?period=', 'Recent disbursements'),
    ('POST', assistantChat, 'AI assistant reply'),
  ];

  /// Shown in the dashboard footer.
  static const List<String> mainEndpoints = [stores, sales, payroll];
}
