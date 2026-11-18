import '../core/utils/local_date.dart';
import '../core/utils/money.dart';

import 'employee_balance_row_model.dart';
import 'month_totals_model.dart';

/// `PayrollSummaryOut` from the API contract (API.md / Swagger).
class PayrollSummaryModel {
  const PayrollSummaryModel({
    this.currency = 'TJS',
    required this.asOf,
    required this.employeesCount,
    required this.totalDue,
    required this.totalPaid,
    required this.totalRemaining,
    required this.currentMonth,
    required this.items,
  });

  factory PayrollSummaryModel.fromJson(Map<String, dynamic> json) =>
      PayrollSummaryModel(
        currency: (json['currency'] ?? 'TJS') as String,
        asOf: parseLocalDate(json['asOf'] as String),
        employeesCount: json['employeesCount'] as int,
        totalDue: parseMoney(json['totalDue'] as String),
        totalPaid: parseMoney(json['totalPaid'] as String),
        totalRemaining: parseMoney(json['totalRemaining'] as String),
        currentMonth: MonthTotalsModel.fromJson(
          json['currentMonth'] as Map<String, dynamic>,
        ),
        items: [
          for (final e in json['items'] as List<dynamic>)
            EmployeeBalanceRowModel.fromJson(e as Map<String, dynamic>),
        ],
      );

  final String currency;
  final DateTime asOf;
  final int employeesCount;
  final double totalDue;
  final double totalPaid;
  final double totalRemaining;
  final MonthTotalsModel currentMonth;
  final List<EmployeeBalanceRowModel> items;
}
