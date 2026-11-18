import '../core/utils/money.dart';

import 'payroll_year_month_model.dart';

/// `PayrollYearOut` from the API contract (API.md / Swagger).
class PayrollYearModel {
  const PayrollYearModel({
    this.currency = 'TJS',
    required this.year,
    required this.totalDue,
    required this.totalPaid,
    required this.totalRemaining,
    required this.months,
  });

  factory PayrollYearModel.fromJson(Map<String, dynamic> json) =>
      PayrollYearModel(
        currency: (json['currency'] ?? 'TJS') as String,
        year: json['year'] as int,
        totalDue: parseMoney(json['totalDue'] as String),
        totalPaid: parseMoney(json['totalPaid'] as String),
        totalRemaining: parseMoney(json['totalRemaining'] as String),
        months: [
          for (final e in json['months'] as List<dynamic>)
            PayrollYearMonthModel.fromJson(e as Map<String, dynamic>),
        ],
      );

  final String currency;
  final int year;
  final double totalDue;
  final double totalPaid;
  final double totalRemaining;
  final List<PayrollYearMonthModel> months;
}
