import 'insight_model.dart';
import 'kpi_model.dart';
import 'sales_point_model.dart';

class DashboardModel {
  const DashboardModel({required this.kpis, required this.sales, required this.insights});

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    kpis: _list(json['kpis'], KpiModel.fromJson),
    sales: _list(json['sales'], SalesPointModel.fromJson),
    insights: _list(json['insights'], InsightModel.fromJson),
  );

  final List<KpiModel> kpis;
  final List<SalesPointModel> sales;
  final List<InsightModel> insights;

  static List<T> _list<T>(Object? raw, T Function(Map<String, dynamic>) fromJson) =>
      (raw as List? ?? const []).map((e) => fromJson(e as Map<String, dynamic>)).toList();

  Map<String, dynamic> toJson() => {
    'kpis': kpis.map((e) => e.toJson()).toList(),
    'sales': sales.map((e) => e.toJson()).toList(),
    'insights': insights.map((e) => e.toJson()).toList(),
  };
}
