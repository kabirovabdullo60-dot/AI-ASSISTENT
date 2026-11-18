import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/employee_payroll_model.dart';
import '../services/payroll_service.dart';

/// One employee's salary: totals, months, payments (cancellable).
class EmployeePayrollViewModel extends ChangeNotifier {
  EmployeePayrollViewModel(this._payroll, this.employeeId);

  final PayrollService _payroll;
  final String employeeId;

  EmployeePayrollModel? _data;
  bool _isLoading = false;
  Object? _error;

  EmployeePayrollModel? get data => _data;
  bool get isLoading => _isLoading;
  bool get hasData => _data != null;
  Object? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _payroll.employee(employeeId);
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancels a payment and reloads the balances.
  Future<void> cancelPayment(String paymentId) async {
    await _payroll.cancel(paymentId);
    await load();
  }
}
