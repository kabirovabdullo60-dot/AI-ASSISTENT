import '../core/utils/money.dart';

/// `HourSalesOut` from the API contract (API.md / Swagger).
class HourSalesModel {
  const HourSalesModel({
    required this.hour,
    required this.totalAmount,
    required this.salesCount,
  });

  factory HourSalesModel.fromJson(Map<String, dynamic> json) => HourSalesModel(
    hour: json['hour'] as int,
    totalAmount: parseMoney(json['totalAmount'] as String),
    salesCount: json['salesCount'] as int,
  );

  /// 0–23, Asia/Dushanbe.
  final int hour;
  final double totalAmount;
  final int salesCount;
}
