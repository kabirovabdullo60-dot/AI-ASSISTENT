import '../core/utils/json.dart';

/// One store inside a sales report / store comparison.
class StoreSalesModel {
  const StoreSalesModel({
    required this.storeId,
    required this.storeName,
    required this.isActive,
    required this.totalAmount,
    required this.salesCount,
    required this.averageSaleAmount,
    required this.sharePercent,
    required this.previousTotalAmount,
    this.changePercent,
    this.rank = 0,
    this.activeEmployees = 0,
  });

  factory StoreSalesModel.fromJson(Map<String, dynamic> json) => StoreSalesModel(
    storeId: asString(json['storeId']),
    storeName: asString(json['storeName']),
    isActive: asString(json['status'], 'ACTIVE') == 'ACTIVE',
    totalAmount: asDouble(json['totalAmount']),
    salesCount: asInt(json['salesCount']),
    averageSaleAmount: asDouble(json['averageSaleAmount']),
    sharePercent: asDouble(json['sharePercent']),
    previousTotalAmount: asDouble(json['previousTotalAmount']),
    changePercent: asDoubleOrNull(json['changePercent']),
    rank: asInt(json['rank']),
    activeEmployees: asInt(json['activeEmployees']),
  );

  final String storeId;
  final String storeName;
  final bool isActive;
  final double totalAmount;
  final int salesCount;
  final double averageSaleAmount;

  /// 0..100
  final double sharePercent;
  final double previousTotalAmount;

  /// `null` when there is no previous period to compare.
  final double? changePercent;
  final int rank;
  final int activeEmployees;
}

/// One day inside a sales report.
class DaySalesModel {
  const DaySalesModel({required this.date, required this.totalAmount, required this.salesCount});

  factory DaySalesModel.fromJson(Map<String, dynamic> json) => DaySalesModel(
    date: asDay(json['saleDate']),
    totalAmount: asDouble(json['totalAmount']),
    salesCount: asInt(json['salesCount']),
  );

  final DateTime date;
  final double totalAmount;
  final int salesCount;
}

/// SalesReportOut and StoreComparisonOut — /api/sales/daily|weekly|monthly,
/// /api/reports/weekly-sales|monthly-sales|store-comparison.
class SalesReportModel {
  const SalesReportModel({
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.salesCount,
    this.averageSaleAmount = 0,
    this.previousTotalAmount = 0,
    this.changePercent,
    this.stores = const [],
    this.byDay = const [],
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    final period = json['period'] is Map ? Map<String, dynamic>.from(json['period'] as Map) : const {};
    return SalesReportModel(
      startDate: asDay(period['startDate']),
      endDate: asDay(period['endDate']),
      totalAmount: asDouble(json['totalAmount']),
      salesCount: asInt(json['salesCount']),
      averageSaleAmount: asDouble(json['averageSaleAmount']),
      previousTotalAmount: asDouble(json['previousTotalAmount']),
      changePercent: asDoubleOrNull(json['changePercent']),
      stores: asJsonList(json['stores']).map(StoreSalesModel.fromJson).toList(),
      byDay: asJsonList(json['byDay']).map(DaySalesModel.fromJson).toList(),
    );
  }

  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final int salesCount;
  final double averageSaleAmount;
  final double previousTotalAmount;
  final double? changePercent;
  final List<StoreSalesModel> stores;
  final List<DaySalesModel> byDay;

  StoreSalesModel? storeById(String id) {
    for (final s in stores) {
      if (s.storeId == id) return s;
    }
    return null;
  }
}
