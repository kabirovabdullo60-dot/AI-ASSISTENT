import '../core/utils/money.dart';

/// `MonthTotalsOut` from the API contract (API.md / Swagger).
class MonthTotalsModel {
  const MonthTotalsModel({
    required this.year,
    required this.month,
    required this.dueAmount,
    required this.paidAmount,
    required this.remainingAmount,
  });

  factory MonthTotalsModel.fromJson(Map<String, dynamic> json) =>
      MonthTotalsModel(
        year: json['year'] as int,
        month: json['month'] as int,
        dueAmount: parseMoney(json['dueAmount'] as String),
        paidAmount: parseMoney(json['paidAmount'] as String),
        remainingAmount: parseMoney(json['remainingAmount'] as String),
      );

  final int year;
  final int month;
  final double dueAmount;
  final double paidAmount;
  final double remainingAmount;
}
