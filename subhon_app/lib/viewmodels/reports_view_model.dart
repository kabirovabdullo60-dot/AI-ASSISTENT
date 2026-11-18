import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/employees_report_model.dart';
import '../models/payroll_year_model.dart';
import '../models/store_comparison_model.dart';
import '../services/reports_service.dart';

/// Reports: stores compared (this month), payroll of a year, employees.
class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel(this._reports, {DateTime? now})
    : _year = (now ?? DateTime.now()).year;

  final ReportsService _reports;

  int _year;
  StoreComparisonModel? _stores;
  PayrollYearModel? _payroll;
  EmployeesReportModel? _employees;
  bool _isLoading = false;
  Object? _error;

  int get year => _year;
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
      ]);
      _stores = results[0] as StoreComparisonModel;
      _payroll = results[1] as PayrollYearModel;
      _employees = results[2] as EmployeesReportModel;
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
