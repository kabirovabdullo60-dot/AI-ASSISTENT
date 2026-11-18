import '../models/payment_create_model.dart';
import '../services/payroll_service.dart';
import 'form_view_model.dart';

/// Records a salary payment for one employee and month. Refused with
/// `PAYROLL_AMOUNT_EXCEEDS_REMAINING`, `PAYROLL_ALREADY_PAID`…
class PaymentFormViewModel extends FormViewModel {
  PaymentFormViewModel(this._payroll);

  final PayrollService _payroll;

  Future<bool> pay({
    required String employeeId,
    required int month,
    required int year,
    required double amount,
    required DateTime paymentDate,
    required String note,
  }) => submit(
    () => _payroll.pay(
      PaymentCreateModel(
        employeeId: employeeId,
        amount: amount,
        month: month,
        year: year,
        paymentDate: paymentDate,
        note: note.trim().isEmpty ? null : note.trim(),
      ),
    ),
  );
}
