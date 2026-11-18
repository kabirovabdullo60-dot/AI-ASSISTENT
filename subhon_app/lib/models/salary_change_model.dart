import '../core/utils/local_date.dart';
import '../core/utils/money.dart';

/// `SalaryChangeOut` from the API contract (API.md / Swagger).
class SalaryChangeModel {
  const SalaryChangeModel({
    required this.monthlySalary,
    required this.effectiveFrom,
    required this.createdAt,
  });

  factory SalaryChangeModel.fromJson(Map<String, dynamic> json) =>
      SalaryChangeModel(
        monthlySalary: parseMoney(json['monthlySalary'] as String),
        effectiveFrom: parseLocalDate(json['effectiveFrom'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );

  final double monthlySalary;
  final DateTime effectiveFrom;
  final DateTime createdAt;
}
