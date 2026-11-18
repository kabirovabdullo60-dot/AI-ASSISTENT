import '../core/utils/money.dart';

/// `PayrollYearMonthOut` from the API contract (API.md / Swagger).
class PayrollYearMonthModel {
  const PayrollYearMonthModel({
    required this.month,
    required this.dueAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.employeesCount,
    required this.paidCount,
  });

  factory PayrollYearMonthModel.fromJson(Map<String, dynamic> json) =>
      PayrollYearMonthModel(
        month: json['month'] as int,
        dueAmount: parseMoney(json['dueAmount'] as String),
        paidAmount: parseMoney(json['paidAmount'] as String),
        remainingAmount: parseMoney(json['remainingAmount'] as String),
        employeesCount: json['employeesCount'] as int,
        paidCount: json['paidCount'] as int,
      );

  final int month;
  final double dueAmount;
  final double paidAmount;
  final double remainingAmount;
  final int employeesCount;
  final int paidCount;
}
