import '../core/utils/money.dart';

import 'payroll_status.dart';

/// `PayrollMonthOut` from the API contract (API.md / Swagger).
class PayrollMonthModel {
  const PayrollMonthModel({
    required this.year,
    required this.month,
    required this.monthlySalary,
    required this.workedDays,
    required this.dueAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.paymentsCount,
  });

  factory PayrollMonthModel.fromJson(Map<String, dynamic> json) =>
      PayrollMonthModel(
        year: json['year'] as int,
        month: json['month'] as int,
        monthlySalary: parseMoney(json['monthlySalary'] as String),
        workedDays: json['workedDays'] as int,
        dueAmount: parseMoney(json['dueAmount'] as String),
        paidAmount: parseMoney(json['paidAmount'] as String),
        remainingAmount: parseMoney(json['remainingAmount'] as String),
        status: PayrollStatus.fromJson(json['status'] as String),
        paymentsCount: json['paymentsCount'] as int,
      );

  final int year;
  final int month;
  final double monthlySalary;
  final int workedDays;
  final double dueAmount;
  final double paidAmount;
  final double remainingAmount;
  final PayrollStatus status;
  final int paymentsCount;
}
