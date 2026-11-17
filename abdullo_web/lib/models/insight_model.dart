enum InsightLevel { success, warning, info }

/// A short AI tip shown on the dashboard.
class InsightModel {
  const InsightModel({required this.title, required this.description, this.level = InsightLevel.info});

  factory InsightModel.fromJson(Map<String, dynamic> json) => InsightModel(
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    level: InsightLevel.values.asNameMap()[json['level']] ?? InsightLevel.info,
  );

  final String title;
  final String description;
  final InsightLevel level;

  Map<String, dynamic> toJson() => {'title': title, 'description': description, 'level': level.name};
}
