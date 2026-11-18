import '../core/utils/local_date.dart';

/// `PaymentCreate` from the API contract (API.md / Swagger).
class PaymentCreateModel {
  const PaymentCreateModel({
    required this.employeeId,
    required this.amount,
    required this.month,
    required this.year,
    this.paymentDate,
    this.note,
  });

  final String employeeId;
  final double amount;
  final int month;
  final int year;
  final DateTime? paymentDate;
  final String? note;

  Map<String, dynamic> toJson() => {
    'employeeId': employeeId,
    'amount': amount.toStringAsFixed(2),
    'month': month,
    'year': year,
    if (paymentDate != null) 'paymentDate': formatLocalDate(paymentDate!),
    'note': ?note,
  };
}
