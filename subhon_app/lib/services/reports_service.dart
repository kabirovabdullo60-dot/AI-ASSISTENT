import '../core/network/api_client.dart';
import '../core/utils/local_date.dart';
import '../models/dashboard_model.dart';
import '../models/employees_report_model.dart';
import '../models/payroll_year_model.dart';
import '../models/profit_model.dart';
import '../models/sales_report_model.dart';
import '../models/store_comparison_model.dart';

/// `Reports` (API.md).
class ReportsService {
  ReportsService(this._api);

  final ApiClient _api;

  Future<DashboardModel> dashboard() async => DashboardModel.fromJson(
    await _api.get('/api/reports/dashboard') as Map<String, dynamic>,
  );

  /// The current month when no month / year is given.
  Future<SalesReportModel> monthlySales({int? month, int? year}) async =>
      SalesReportModel.fromJson(
        await _api.get(
              '/api/reports/monthly-sales',
              query: {'month': month, 'year': year},
            )
            as Map<String, dynamic>,
      );

  /// The current Monday–Sunday week when no dates are given; any range of
  /// 1–366 days otherwise.
  Future<SalesReportModel> weeklySales({
    DateTime? startDate,
    DateTime? endDate,
  }) async => SalesReportModel.fromJson(
    await _api.get(
          '/api/reports/weekly-sales',
          query: _range(startDate, endDate),
        )
        as Map<String, dynamic>,
  );

  /// Sales − expenses − salary due; the current month when no dates are
  /// given.
  Future<ProfitModel> profit({DateTime? startDate, DateTime? endDate}) async =>
      ProfitModel.fromJson(
        await _api.get('/api/reports/profit', query: _range(startDate, endDate))
            as Map<String, dynamic>,
      );

  static Map<String, Object?> _range(DateTime? startDate, DateTime? endDate) =>
      {
        'startDate': startDate == null ? null : formatLocalDate(startDate),
        'endDate': endDate == null ? null : formatLocalDate(endDate),
      };

  Future<StoreComparisonModel> storeComparison({
    DateTime? startDate,
    DateTime? endDate,
  }) async => StoreComparisonModel.fromJson(
    await _api.get(
          '/api/reports/store-comparison',
          query: {
            'startDate': startDate == null ? null : formatLocalDate(startDate),
            'endDate': endDate == null ? null : formatLocalDate(endDate),
          },
        )
        as Map<String, dynamic>,
  );

  Future<EmployeesReportModel> employees() async =>
      EmployeesReportModel.fromJson(
        await _api.get('/api/reports/employees') as Map<String, dynamic>,
      );

  Future<PayrollYearModel> payroll({int? year}) async =>
      PayrollYearModel.fromJson(
        await _api.get('/api/reports/payroll', query: {'year': year})
            as Map<String, dynamic>,
      );
}
