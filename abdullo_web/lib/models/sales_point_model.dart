/// One bar of the sales chart, e.g. Nov = 48,250.
class SalesPointModel {
  const SalesPointModel({required this.label, required this.value});

  factory SalesPointModel.fromJson(Map<String, dynamic> json) =>
      SalesPointModel(label: json['label'] as String? ?? '', value: (json['value'] as num? ?? 0).toDouble());

  final String label;
  final double value;

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}
