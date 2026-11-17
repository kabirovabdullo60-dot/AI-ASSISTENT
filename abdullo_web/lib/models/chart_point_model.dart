import '../core/utils/json.dart';

/// One day on the revenue chart: bar = revenue, line = cashflow.
class ChartPointModel {
  const ChartPointModel({required this.date, required this.revenue, required this.cashflow});

  factory ChartPointModel.fromJson(Map<String, dynamic> json) => ChartPointModel(
    date: asDate(json['date']),
    revenue: asDouble(json['revenue']),
    cashflow: asDouble(json['cashflow']),
  );

  final DateTime date;
  final double revenue;
  final double cashflow;

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'revenue': revenue, 'cashflow': cashflow};
}
