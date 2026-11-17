import '../core/utils/json.dart';
import 'chart_point_model.dart';
import 'sale_model.dart';

/// GET /stores/{id}/analytics — the store detail panel.
class StoreAnalyticsModel {
  const StoreAnalyticsModel({required this.storeId, required this.last7Days, required this.recent});

  factory StoreAnalyticsModel.fromJson(Map<String, dynamic> json) => StoreAnalyticsModel(
    storeId: asString(json['storeId']),
    last7Days: asJsonList(json['last7Days']).map(ChartPointModel.fromJson).toList(),
    recent: asJsonList(json['recent']).map(SaleModel.fromJson).toList(),
  );

  final String storeId;

  /// Oldest first, last one is today.
  final List<ChartPointModel> last7Days;

  /// Latest sales entries of this store.
  final List<SaleModel> recent;

  double get average => last7Days.isEmpty ? 0 : last7Days.fold<double>(0, (s, p) => s + p.revenue) / last7Days.length;

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'last7Days': last7Days.map((e) => e.toJson()).toList(),
    'recent': recent.map((e) => e.toJson()).toList(),
  };
}
