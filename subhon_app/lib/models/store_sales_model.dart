import '../core/utils/money.dart';

import 'store_status.dart';

/// `StoreSalesOut` from the API contract (API.md / Swagger).
class StoreSalesModel {
  const StoreSalesModel({
    required this.storeId,
    required this.storeName,
    required this.status,
    required this.isDeleted,
    required this.totalAmount,
    required this.salesCount,
    required this.averageSaleAmount,
    required this.sharePercent,
    required this.previousTotalAmount,
    required this.previousSalesCount,
    required this.changeAmount,
    this.changePercent,
  });

  factory StoreSalesModel.fromJson(Map<String, dynamic> json) =>
      StoreSalesModel(
        storeId: json['storeId'] as String,
        storeName: json['storeName'] as String,
        status: StoreStatus.fromJson(json['status'] as String),
        isDeleted: json['isDeleted'] as bool,
        totalAmount: parseMoney(json['totalAmount'] as String),
        salesCount: json['salesCount'] as int,
        averageSaleAmount: parseMoney(json['averageSaleAmount'] as String),
        sharePercent: (json['sharePercent'] as num).toDouble(),
        previousTotalAmount: parseMoney(json['previousTotalAmount'] as String),
        previousSalesCount: json['previousSalesCount'] as int,
        changeAmount: parseMoney(json['changeAmount'] as String),
        changePercent: json['changePercent'] == null
            ? null
            : (json['changePercent'] as num).toDouble(),
      );

  final String storeId;
  final String storeName;
  final StoreStatus status;
  final bool isDeleted;
  final double totalAmount;
  final int salesCount;
  final double averageSaleAmount;
  final double sharePercent;
  final double previousTotalAmount;
  final int previousSalesCount;
  final double changeAmount;
  final double? changePercent;
}
