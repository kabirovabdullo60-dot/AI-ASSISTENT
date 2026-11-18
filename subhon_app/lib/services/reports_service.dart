import '../core/network/api_client.dart';
import '../core/utils/local_date.dart';
import '../models/dashboard_model.dart';
import '../models/employees_report_model.dart';
import '../models/payroll_year_model.dart';
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
