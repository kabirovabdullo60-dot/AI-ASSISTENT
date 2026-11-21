import 'target_period.dart';

/// `TargetPut` from the API contract (API.md / Swagger).
class TargetPutModel {
  const TargetPutModel({
    required this.period,
    required this.amount,
    this.storeId,
  });

  final TargetPeriod period;
  final double amount;

  /// `null`: the whole business.
  final String? storeId;

  Map<String, dynamic> toJson() => {
    'period': period.json,
    'storeId': storeId,
    'amount': amount.toStringAsFixed(2),
  };
}
