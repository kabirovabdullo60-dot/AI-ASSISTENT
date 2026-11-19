import '../core/utils/local_date.dart';
import 'salary_payment_method.dart';

/// `PaymentCreate` from the API contract (API.md / Swagger).
class PaymentCreateModel {
  const PaymentCreateModel({
    required this.employeeId,
    required this.amount,
    required this.month,
    required this.year,
    this.paymentDate,
    this.note,
    this.method,
  });

  final String employeeId;
  final double amount;
  final int month;
  final int year;
  final DateTime? paymentDate;
  final String? note;

  /// How it was paid (optional).
  final SalaryPaymentMethod? method;

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'amount': amount.toStringAsFixed(2),
    'month': month,
    'year': year,
    if (paymentDate != null) 'paymentDate': formatLocalDate(paymentDate!),
    'note': ?note,
    if (method != null) 'method': method!.json,
  };
}
