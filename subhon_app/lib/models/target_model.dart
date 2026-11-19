import '../core/utils/money.dart';
import 'target_period.dart';

/// `TargetOut` from the API contract (API.md / Swagger).
class TargetModel {
  const TargetModel({
    required this.id,
    required this.period,
    required this.storeId,
    required this.storeName,
    required this.amount,
  });

  factory TargetModel.fromJson(Map<String, dynamic> json) => TargetModel(
    id: json['id'] as String,
    period: TargetPeriod.fromJson(json['period'] as String),
    storeId: json['storeId'] as String?,
    storeName: json['storeName'] as String?,
    amount: parseMoney(json['amount'] as String),
  );

  final String id;
  final TargetPeriod period;

  /// `null`: the whole business.
  final String? storeId;
  final String? storeName;
  final double amount;
}
