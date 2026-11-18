import '../core/utils/money.dart';

/// `TopStoreOut` from the API contract (API.md / Swagger).
class TopStoreModel {
  const TopStoreModel({
    required this.storeId,
    required this.storeName,
    required this.totalAmount,
    required this.salesCount,
  });

  factory TopStoreModel.fromJson(Map<String, dynamic> json) => TopStoreModel(
    storeId: json['storeId'] as String,
    storeName: json['storeName'] as String,
    totalAmount: parseMoney(json['totalAmount'] as String),
    salesCount: json['salesCount'] as int,
  );

  final String storeId;
  final String storeName;
  final double totalAmount;
  final int salesCount;
}
