import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/monthly_payroll_model.dart';
import '../services/payroll_service.dart';

/// Salaries of one month: every employee with PAID / PARTIAL / UNPAID.
class PayrollViewModel extends ChangeNotifier {
  PayrollViewModel(this._payroll, {DateTime? now}) {
    final today = now ?? DateTime.now();
    _month = today.month;
    _year = today.year;
  }

  final PayrollService _payroll;

  late int _month;
  late int _year;
  MonthlyPayrollModel? _data;
  bool _isLoading = false;
  Object? _error;

  int get month => _month;
  int get year => _year;
  MonthlyPayrollModel? get data => _data;
  bool get isLoading => _isLoading;
  bool get hasData => _data != null;
  Object? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _payroll.monthly(month: _month, year: _year);
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Moves to the previous (`-1`) or next (`+1`) month and loads it.
  Future<void> shiftMonth(int delta) {
    final date = DateTime(_year, _month + delta);
    _month = date.month;
    _year = date.year;
    _data = null;
    return load();
  }
}
