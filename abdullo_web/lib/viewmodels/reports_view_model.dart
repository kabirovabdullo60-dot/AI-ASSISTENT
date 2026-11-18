import '../core/utils/format.dart';
import '../models/employees_report_model.dart';
import '../models/payment_model.dart';
import '../models/sales_report_model.dart';
import '../services/reports_service.dart';
import 'base_view_model.dart';

/// Reports page: store comparison (this month), employees and the yearly payroll.
class ReportsViewModel extends BaseViewModel {
  ReportsViewModel(this._reports);

  final ReportsService _reports;
  SalesReportModel? _comparison;
  EmployeesReportModel? _employees;
  PayrollYearModel? _payroll;
  int _year = DateTime.now().year;

  SalesReportModel? get comparison => _comparison;
  EmployeesReportModel? get employees => _employees;
  PayrollYearModel? get payroll => _payroll;
  int get year => _year;
  bool get hasData => _comparison != null && _employees != null && _payroll != null;

  List<StoreSalesModel> get ranked =>
      List.of(_comparison?.stores ?? const <StoreSalesModel>[])..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  Future<void> load() => runTask(() async {
    final now = DateTime.now();
    final (comparison, employees, payroll) = await (
      _reports.storeComparison(startDate: DateTime(now.year, now.month), endDate: dateOnly(now)),
      _reports.employees(),
      _reports.payrollYear(_year),
    ).wait;
    _comparison = comparison;
    _employees = employees;
    _payroll = payroll;
  });

  Future<void> setYear(int year) async {
    _year = year;
    await runTask(() async => _payroll = await _reports.payrollYear(year));
  }
}
