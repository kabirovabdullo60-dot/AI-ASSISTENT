import '../core/utils/local_date.dart';

/// One repayment of a debt.
class DebtPaymentModel {
  const DebtPaymentModel({required this.amount, required this.date, this.note});

  factory DebtPaymentModel.fromJson(Map<String, dynamic> json) =>
      DebtPaymentModel(
        amount: (json['amount'] as num).toDouble(),
        date: parseLocalDate(json['date'] as String),
        note: json['note'] as String?,
      );

  final double amount;
  final DateTime date;
  final String? note;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'date': formatLocalDate(date),
    'note': ?note,
  };
}
