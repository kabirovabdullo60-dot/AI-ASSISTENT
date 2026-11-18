import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/dashboard_model.dart';
import '../models/employees_report_model.dart';
import '../models/payment_model.dart';
import '../models/profit_model.dart';
import '../models/sales_report_model.dart';

class ReportsService {
  ReportsService(this._api);

  final ApiClient _api;

  Future<DashboardModel> dashboard() async =>
      DashboardModel.fromJson(asJsonMap(await _api.get(ApiConstants.reportDashboard)));

  Future<SalesReportModel> weeklySales({DateTime? startDate, DateTime? endDate}) async => SalesReportModel.fromJson(
    asJsonMap(
      await _api.get(
        ApiConstants.reportWeeklySales,
        query: {
          'startDate': startDate == null ? null : isoDay(startDate),
          'endDate': endDate == null ? null : isoDay(endDate),
        },
      ),
    ),
  );

  Future<SalesReportModel> monthlySales({int? month, int? year}) async => SalesReportModel.fromJson(
    asJsonMap(await _api.get(ApiConstants.reportMonthlySales, query: {'month': month, 'year': year})),
  );

  Future<SalesReportModel> storeComparison({DateTime? startDate, DateTime? endDate}) async => SalesReportModel.fromJson(
    asJsonMap(
      await _api.get(
        ApiConstants.reportStoreComparison,
        query: {
          'startDate': startDate == null ? null : isoDay(startDate),
          'endDate': endDate == null ? null : isoDay(endDate),
        },
      ),
    ),
  );

  Future<EmployeesReportModel> employees() async =>
      EmployeesReportModel.fromJson(asJsonMap(await _api.get(ApiConstants.reportEmployees)));

  Future<PayrollYearModel> payrollYear(int year) async =>
      PayrollYearModel.fromJson(asJsonMap(await _api.get(ApiConstants.reportPayroll, query: {'year': year})));

  /// GET /api/reports/profit — defaults to this month; up to 366 days.
  Future<ProfitModel> profit({DateTime? startDate, DateTime? endDate}) async => ProfitModel.fromJson(
    asJsonMap(
      await _api.get(
        ApiConstants.reportProfit,
        query: {
          'startDate': startDate == null ? null : isoDay(startDate),
          'endDate': endDate == null ? null : isoDay(endDate),
        },
      ),
    ),
  );

  /// GET /health/ready (no auth) — true when the server and database answer.
  Future<bool> healthy() async {
    try {
      final json = asJsonMap(await _api.get(ApiConstants.healthReady, auth: false));
      return json['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }
}
