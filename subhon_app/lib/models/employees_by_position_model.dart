import '../core/utils/money.dart';

/// `EmployeesByPositionOut` from the API contract (API.md / Swagger).
class EmployeesByPositionModel {
  const EmployeesByPositionModel({
    required this.position,
    required this.employeesCount,
    required this.activeEmployees,
    required this.monthlySalaryTotal,
  });

  factory EmployeesByPositionModel.fromJson(Map<String, dynamic> json) =>
      EmployeesByPositionModel(
        position: json['position'] as String,
        employeesCount: json['employeesCount'] as int,
        activeEmployees: json['activeEmployees'] as int,
        monthlySalaryTotal: parseMoney(json['monthlySalaryTotal'] as String),
      );

  final String position;
  final int employeesCount;
  final int activeEmployees;
  final double monthlySalaryTotal;
}
