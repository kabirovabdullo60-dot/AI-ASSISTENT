import '../core/utils/local_date.dart';

/// `PeriodOut` from the API contract (API.md / Swagger).
class PeriodModel {
  const PeriodModel({
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory PeriodModel.fromJson(Map<String, dynamic> json) => PeriodModel(
    startDate: parseLocalDate(json['startDate'] as String),
    endDate: parseLocalDate(json['endDate'] as String),
    days: json['days'] as int,
  );

  final DateTime startDate;
  final DateTime endDate;
  final int days;
}
