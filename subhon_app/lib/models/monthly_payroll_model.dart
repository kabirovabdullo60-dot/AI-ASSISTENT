import '../core/utils/money.dart';

import 'monthly_payroll_row_model.dart';

/// `MonthlyPayrollOut` from the API contract (API.md / Swagger).
class MonthlyPayrollModel {
  const MonthlyPayrollModel({
    this.currency = 'TJS',
    required this.year,
    required this.month,
    required this.employeesCount,
    required this.totalDue,
    required this.totalPaid,
    required this.totalRemaining,
    required this.paidCount,
    required this.partialCount,
    required this.unpaidCount,
    required this.items,
  });

  factory MonthlyPayrollModel.fromJson(Map<String, dynamic> json) =>
      MonthlyPayrollModel(
        currency: (json['currency'] ?? 'TJS') as String,
        year: json['year'] as int,
        month: json['month'] as int,
        employeesCount: json['employeesCount'] as int,
        totalDue: parseMoney(json['totalDue'] as String),
        totalPaid: parseMoney(json['totalPaid'] as String),
        totalRemaining: parseMoney(json['totalRemaining'] as String),
        paidCount: json['paidCount'] as int,
        partialCount: json['partialCount'] as int,
        unpaidCount: json['unpaidCount'] as int,
        items: [
          for (final e in json['items'] as List<dynamic>)
            MonthlyPayrollRowModel.fromJson(e as Map<String, dynamic>),
        ],
      );

  final String currency;
  final int year;
  final int month;
  final int employeesCount;
  final double totalDue;
  final double totalPaid;
  final double totalRemaining;
  final int paidCount;
  final int partialCount;
  final int unpaidCount;
  final List<MonthlyPayrollRowModel> items;
}
