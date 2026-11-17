import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';
import '../models/insight_model.dart';
import '../models/kpi_model.dart';
import '../models/sales_point_model.dart';

class DashboardService {
  DashboardService({
    ApiClient? client,
    this.useMock = ApiConstants.useMock,
    this.mockDelay = const Duration(milliseconds: 400),
  }) : _client = client ?? ApiClient();

  final ApiClient _client;
  final bool useMock;
  final Duration mockDelay;

  Future<DashboardModel> fetchDashboard() async {
    if (useMock) {
      await Future<void>.delayed(mockDelay);
      return mockDashboard;
    }
    final json = await _client.get(ApiConstants.dashboardPath);
    return DashboardModel.fromJson(json as Map<String, dynamic>);
  }

  /// Demo data until Mehroj's backend is ready.
  static const mockDashboard = DashboardModel(
    kpis: [
      KpiModel(title: 'Revenue', value: 48250, unit: 'TJS', changePercent: 12.4),
      KpiModel(title: 'Expenses', value: 31780, unit: 'TJS', changePercent: 4.1, higherIsBetter: false),
      KpiModel(title: 'Profit', value: 16470, unit: 'TJS', changePercent: 18.2),
      KpiModel(title: 'Customers', value: 312, changePercent: 6.8),
    ],
    sales: [
      SalesPointModel(label: 'Jun', value: 32100),
      SalesPointModel(label: 'Jul', value: 35400),
      SalesPointModel(label: 'Aug', value: 33800),
      SalesPointModel(label: 'Sep', value: 39900),
      SalesPointModel(label: 'Oct', value: 43000),
      SalesPointModel(label: 'Nov', value: 48250),
    ],
    insights: [
      InsightModel(
        title: 'Sales are growing',
        description: 'Revenue rose 3 months in a row. November is your best month so far.',
        level: InsightLevel.success,
      ),
      InsightModel(
        title: 'Watch delivery costs',
        description: 'Delivery takes 22% of expenses. Grouping orders could save about 1,500 TJS a month.',
        level: InsightLevel.warning,
      ),
      InsightModel(
        title: 'Bring customers back',
        description: '41 customers have not bought in 60 days. A small discount message could win them back.',
      ),
    ],
  );
}
