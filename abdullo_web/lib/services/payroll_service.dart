import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/page_model.dart';
import '../models/payment_model.dart';
import '../models/payroll_model.dart';

class PayrollService {
  PayrollService(this._api);

  final ApiClient _api;

  Future<MonthlyPayrollModel> monthly({required int month, required int year, String? storeId}) async =>
      MonthlyPayrollModel.fromJson(
        asJsonMap(
          await _api.get(ApiConstants.payrollMonthly, query: {'month': month, 'year': year, 'storeId': storeId}),
        ),
      );

  /// Payments made for a month (newest first).
  Future<PageModel<PaymentModel>> payments({int? month, int? year, String? employeeId, int limit = 20}) async =>
      PageModel.fromJson(
        await _api.get(
          ApiConstants.payroll,
          query: {'month': month, 'year': year, 'employeeId': employeeId, 'limit': limit, 'sort': '-createdAt'},
        ),
        PaymentModel.fromJson,
      );

  Future<PaymentModel> pay({
    required String employeeId,
    required double amount,
    required int month,
    required int year,
    DateTime? paymentDate,
    String? note,
  }) async => PaymentModel.fromJson(
    asJsonMap(
      await _api.post(ApiConstants.payroll, {
        'employeeId': employeeId,
        'amount': money(amount),
        'month': month,
        'year': year,
        if (paymentDate != null) 'paymentDate': isoDay(paymentDate),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      }),
    ),
  );

  /// Cancels a payment (soft delete).
  Future<void> cancel(String paymentId) => _api.delete(ApiConstants.payment(paymentId));

  Future<EmployeePayrollModel> ofEmployee(String employeeId) async =>
      EmployeePayrollModel.fromJson(asJsonMap(await _api.get(ApiConstants.payrollOfEmployee(employeeId))));
}
