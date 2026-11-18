import '../core/utils/money.dart';

/// `PeriodBalanceOut` from the API contract (API.md / Swagger).
class PeriodBalanceModel {
  const PeriodBalanceModel({
    required this.dueAmount,
    required this.paidAmount,
    required this.remainingAmount,
  });

  factory PeriodBalanceModel.fromJson(Map<String, dynamic> json) =>
      PeriodBalanceModel(
        dueAmount: parseMoney(json['dueAmount'] as String),
        paidAmount: parseMoney(json['paidAmount'] as String),
        remainingAmount: parseMoney(json['remainingAmount'] as String),
      );

  final double dueAmount;
  final double paidAmount;
  final double remainingAmount;
}
