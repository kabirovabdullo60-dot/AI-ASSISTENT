import '../core/utils/format.dart';

/// One number on the dashboard, e.g. Revenue 48,250 TJS (+12.4%).
class KpiModel {
  const KpiModel({
    required this.title,
    required this.value,
    this.unit = '',
    this.changePercent,
    this.higherIsBetter = true,
  });

  factory KpiModel.fromJson(Map<String, dynamic> json) => KpiModel(
    title: json['title'] as String? ?? '',
    value: (json['value'] as num? ?? 0).toDouble(),
    unit: json['unit'] as String? ?? '',
    changePercent: (json['changePercent'] as num?)?.toDouble(),
    higherIsBetter: json['higherIsBetter'] as bool? ?? true,
  );

  final String title;
  final double value;
  final String unit;

  /// Change vs the previous period, in percent. `null` = not shown.
  final double? changePercent;

  /// For expenses a rise is bad, so the arrow turns red.
  final bool higherIsBetter;

  String get displayValue => unit.isEmpty ? formatAmount(value) : '${formatAmount(value)} $unit';

  bool get isGoodChange {
    final change = changePercent ?? 0;
    return higherIsBetter ? change >= 0 : change <= 0;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'value': value,
    'unit': unit,
    'changePercent': changePercent,
    'higherIsBetter': higherIsBetter,
  };
}
