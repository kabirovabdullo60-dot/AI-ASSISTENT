import '../core/utils/money.dart';

import 'period_model.dart';
import 'store_comparison_row_model.dart';

/// `StoreComparisonOut` from the API contract (API.md / Swagger).
class StoreComparisonModel {
  const StoreComparisonModel({
    this.currency = 'TJS',
    required this.period,
    required this.previousPeriod,
    required this.totalAmount,
    required this.salesCount,
    required this.storesCount,
    this.bestStore,
    required this.stores,
  });

  factory StoreComparisonModel.fromJson(Map<String, dynamic> json) =>
      StoreComparisonModel(
        currency: (json['currency'] ?? 'TJS') as String,
        period: PeriodModel.fromJson(json['period'] as Map<String, dynamic>),
        previousPeriod: PeriodModel.fromJson(
          json['previousPeriod'] as Map<String, dynamic>,
        ),
        totalAmount: parseMoney(json['totalAmount'] as String),
        salesCount: json['salesCount'] as int,
        storesCount: json['storesCount'] as int,
        bestStore: json['bestStore'] == null
            ? null
            : StoreComparisonRowModel.fromJson(
                json['bestStore'] as Map<String, dynamic>,
              ),
        stores: [
          for (final e in json['stores'] as List<dynamic>)
            StoreComparisonRowModel.fromJson(e as Map<String, dynamic>),
        ],
      );

  final String currency;
  final PeriodModel period;
  final PeriodModel previousPeriod;
  final double totalAmount;
  final int salesCount;
  final int storesCount;
  final StoreComparisonRowModel? bestStore;
  final List<StoreComparisonRowModel> stores;
}
