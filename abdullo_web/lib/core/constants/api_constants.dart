/// Backend config — Mehroj's API (Swagger: [baseUrl]/docs).
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api-production-86caefb2.up.railway.app';
  static const String docsUrl = '$baseUrl/docs';
  static const Duration timeout = Duration(seconds: 25);

  /// POST /api/assistant/chat answers in a few seconds, at most about 60.
  static const Duration assistantTimeout = Duration(seconds: 75);

  // auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';

  // profile
  static const String profile = '/api/profile';
  static const String profileAvatar = '/api/profile/avatar';
  static const String profilePassword = '/api/profile/password';

  // stores
  static const String stores = '/api/stores';
  static String store(String id) => '/api/stores/$id';

  // sales
  static const String sales = '/api/sales';
  static String sale(String id) => '/api/sales/$id';
  static const String salesDaily = '/api/sales/daily';
  static const String salesWeekly = '/api/sales/weekly';
  static const String salesMonthly = '/api/sales/monthly';
  static String salesOfStore(String storeId) => '/api/sales/store/$storeId';

  // employees
  static const String employees = '/api/employees';
  static String employee(String id) => '/api/employees/$id';
  static String employeesOfStore(String storeId) => '/api/employees/store/$storeId';

  // payroll
  static const String payroll = '/api/payroll';
  static String payment(String id) => '/api/payroll/$id';
  static const String payrollMonthly = '/api/payroll/monthly';
  static const String payrollSummary = '/api/payroll/summary';
  static String payrollOfEmployee(String employeeId) => '/api/payroll/employee/$employeeId';

  // reports
  static const String reportDashboard = '/api/reports/dashboard';
  static const String reportWeeklySales = '/api/reports/weekly-sales';
  static const String reportMonthlySales = '/api/reports/monthly-sales';
  static const String reportStoreComparison = '/api/reports/store-comparison';
  static const String reportEmployees = '/api/reports/employees';
  static const String reportPayroll = '/api/reports/payroll';
  static const String reportProfit = '/api/reports/profit';

  // expenses
  static const String expenses = '/api/expenses';
  static String expense(String id) => '/api/expenses/$id';

  // sales targets (PUT creates or changes)
  static const String targets = '/api/targets';

  // activity log, notifications, AI assistant, server settings
  static const String activity = '/api/activity';
  static const String notifications = '/api/notifications';
  static const String notificationsReadAll = '/api/notifications/read-all';
  static const String assistantChat = '/api/assistant/chat';
  static const String exchangeRates = '/api/settings/exchange-rates';

  // health (no auth)
  static const String healthLive = '/health/live';
  static const String healthReady = '/health/ready';

  /// Method, path, purpose — shown on the Settings page.
  static const List<(String, String, String)> endpointList = [
    ('POST', '$register · $login · $refresh · $logout', 'Auth'),
    ('GET', me, 'Current user'),
    ('GET/PUT', profile, 'Profile'),
    ('PATCH', '$profileAvatar · $profilePassword', 'Avatar, password'),
    ('GET/POST', stores, 'Stores'),
    ('GET/PUT/DELETE', '/api/stores/{id}', 'One store'),
    ('GET/POST', sales, 'Sales'),
    ('GET/PUT/DELETE', '/api/sales/{id}', 'One sale'),
    ('GET', '$salesDaily · $salesWeekly · $salesMonthly', 'Sales reports'),
    ('GET', '/api/sales/store/{storeId}', 'Sales of a store'),
    ('GET/POST', employees, 'Employees'),
    ('GET/PUT/DELETE', '/api/employees/{id}', 'One employee'),
    ('GET', '/api/employees/store/{storeId}', 'Employees of a store'),
    ('GET/POST', payroll, 'Salary payments'),
    ('GET', '$payrollMonthly · $payrollSummary', 'Payroll reports'),
    ('GET', '/api/payroll/employee/{employeeId}', 'Salary history'),
    ('GET/DELETE', '/api/payroll/{id}', 'One payment'),
    ('GET', '/api/reports/*', 'Dashboard, sales, stores, employees, payroll'),
    ('GET/POST', expenses, 'Expenses'),
    ('GET/PUT/DELETE', '/api/expenses/{id}', 'One expense'),
    ('GET/PUT', targets, 'Sales targets'),
    ('GET', reportProfit, 'Profit'),
    ('GET', activity, 'Activity log'),
    ('GET', notifications, 'Notifications'),
    ('POST', notificationsReadAll, 'Mark notifications read'),
    ('GET', exchangeRates, 'Exchange rates'),
    ('POST', assistantChat, 'AI assistant'),
    ('GET', healthReady, 'Server health'),
  ];

  static const List<String> mainEndpoints = [activity, sales, payroll];
}
