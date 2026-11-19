import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/employees_report_model.dart';
import '../models/payroll_year_model.dart';
import '../models/profit_model.dart';
import '../models/store_comparison_model.dart';
import '../services/reports_service.dart';

/// Reports: profit of a month, stores compared (this month), payroll of a
/// year, employees.
class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel(this._reports, {DateTime? now})
    : _now = now ?? DateTime.now(),
      _year = (now ?? DateTime.now()).year,
      _profitMonth = DateTime(
        (now ?? DateTime.now()).year,
        (now ?? DateTime.now()).month,
      );

  final ReportsService _reports;
  final DateTime _now;

  int _year;
  DateTime _profitMonth;
  ProfitModel? _profit;
  StoreComparisonModel? _stores;
  PayrollYearModel? _payroll;
  EmployeesReportModel? _employees;
  bool _isLoading = false;
  Object? _error;

  int get year => _year;

  /// The 1st of the month the profit is shown for.
  DateTime get profitMonth => _profitMonth;
  ProfitModel? get profit => _profit;

  /// No profit for months that have not started.
  bool get canShowNextProfitMonth =>
      _profitMonth.isBefore(DateTime(_now.year, _now.month));
  StoreComparisonModel? get stores => _stores;
  PayrollYearModel? get payroll => _payroll;
  EmployeesReportModel? get employees => _employees;
  bool get isLoading => _isLoading;
  bool get hasData => _stores != null;
  Object? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _reports.storeComparison(),
        _reports.payroll(year: _year),
        _reports.employees(),
        _loadProfit(),
      ]);
      _stores = results[0] as StoreComparisonModel;
      _payroll = results[1] as PayrollYearModel;
      _employees = results[2] as EmployeesReportModel;
      _profit = results[3] as ProfitModel;
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Profit of the month [delta] months away.
  Future<void> shiftProfitMonth(int delta) async {
    _profitMonth = DateTime(_profitMonth.year, _profitMonth.month + delta);
    _profit = null;
    notifyListeners();
    try {
      _profit = await _loadProfit();
    } on ApiException catch (e) {
      _error = e;
    } finally {
      notifyListeners();
    }
  }

  /// The whole month; the current one up to today.
  Future<ProfitModel> _loadProfit() {
    final start = _profitMonth;
    final monthEnd = DateTime(start.year, start.month + 1, 0);
    final today = DateTime(_now.year, _now.month, _now.day);
    return _reports.profit(
      startDate: start,
      endDate: monthEnd.isAfter(today) ? today : monthEnd,
    );
  }

  /// Payroll of another year.
  Future<void> shiftYear(int delta) async {
    _year += delta;
    try {
      _payroll = null;
      notifyListeners();
      _payroll = await _reports.payroll(year: _year);
    } on ApiException catch (e) {
      _error = e;
    } finally {
      notifyListeners();
    }
  }
}
