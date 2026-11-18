import '../core/utils/local_date.dart';
import '../core/utils/money.dart';

/// `DaySalesOut` from the API contract (API.md / Swagger).
class DaySalesModel {
  const DaySalesModel({
    required this.saleDate,
    required this.totalAmount,
    required this.salesCount,
  });

  factory DaySalesModel.fromJson(Map<String, dynamic> json) => DaySalesModel(
    saleDate: parseLocalDate(json['saleDate'] as String),
    totalAmount: parseMoney(json['totalAmount'] as String),
    salesCount: json['salesCount'] as int,
  );

  final DateTime saleDate;
  final double totalAmount;
  final int salesCount;
}
