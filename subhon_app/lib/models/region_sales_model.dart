import '../core/utils/money.dart';

/// `RegionSalesOut` from the API contract (API.md / Swagger).
class RegionSalesModel {
  const RegionSalesModel({
    required this.region,
    required this.storesCount,
    required this.inactiveStores,
    required this.totalAmount,
    required this.sharePercent,
  });

  factory RegionSalesModel.fromJson(Map<String, dynamic> json) =>
      RegionSalesModel(
        region: json['region'] as String?,
        storesCount: json['storesCount'] as int,
        inactiveStores: json['inactiveStores'] as int,
        totalAmount: parseMoney(json['totalAmount'] as String),
        sharePercent: (json['sharePercent'] as num).toDouble(),
      );

  /// `null`: the stores without a region.
  final String? region;
  final int storesCount;
  final int inactiveStores;
  final double totalAmount;
  final double sharePercent;
}
