import '../core/network/api_client.dart';
import '../models/employee_payroll_model.dart';
import '../models/monthly_payroll_model.dart';
import '../models/payment_create_model.dart';
import '../models/payment_model.dart';

/// `Payroll` (API.md): monthly salaries, payments and their history.
class PayrollService {
  PayrollService(this._api);

  final ApiClient _api;

  /// Every employee's salary for one month (PAID / PARTIAL / UNPAID).
  Future<MonthlyPayrollModel> monthly({
    required int month,
    required int year,
    String? storeId,
  }) async => MonthlyPayrollModel.fromJson(
    await _api.get(
          '/api/payroll/monthly',
          query: {'month': month, 'year': year, 'storeId': storeId},
        )
        as Map<String, dynamic>,
  );

  /// Records a salary payment; refused with
  /// `PAYROLL_AMOUNT_EXCEEDS_REMAINING`, `PAYROLL_ALREADY_PAID`…
  Future<PaymentModel> pay(PaymentCreateModel payment) async =>
      PaymentModel.fromJson(
        await _api.post('/api/payroll', body: payment.toJson())
            as Map<String, dynamic>,
      );

  /// One employee: months, payments and salary history.
  Future<EmployeePayrollModel> employee(String employeeId) async =>
      EmployeePayrollModel.fromJson(
        await _api.get('/api/payroll/employee/$employeeId')
            as Map<String, dynamic>,
      );

  /// Cancels a payment (soft delete).
  Future<void> cancel(String paymentId) =>
      _api.delete('/api/payroll/$paymentId');
}
