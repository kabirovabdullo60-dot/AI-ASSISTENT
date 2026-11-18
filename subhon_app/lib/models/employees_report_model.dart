import '../core/utils/money.dart';

import 'employees_by_position_model.dart';
import 'employees_by_store_model.dart';

/// `EmployeesReportOut` from the API contract (API.md / Swagger).
class EmployeesReportModel {
  const EmployeesReportModel({
    this.currency = 'TJS',
    required this.totalEmployees,
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.hiredThisMonth,
    required this.monthlySalaryTotal,
    required this.averageMonthlySalary,
    required this.byStore,
    required this.byPosition,
  });

  factory EmployeesReportModel.fromJson(Map<String, dynamic> json) =>
      EmployeesReportModel(
        currency: (json['currency'] ?? 'TJS') as String,
        totalEmployees: json['totalEmployees'] as int,
        activeEmployees: json['activeEmployees'] as int,
        inactiveEmployees: json['inactiveEmployees'] as int,
        hiredThisMonth: json['hiredThisMonth'] as int,
        monthlySalaryTotal: parseMoney(json['monthlySalaryTotal'] as String),
        averageMonthlySalary: parseMoney(
          json['averageMonthlySalary'] as String,
        ),
        byStore: [
          for (final e in json['byStore'] as List<dynamic>)
            EmployeesByStoreModel.fromJson(e as Map<String, dynamic>),
        ],
        byPosition: [
          for (final e in json['byPosition'] as List<dynamic>)
            EmployeesByPositionModel.fromJson(e as Map<String, dynamic>),
        ],
      );

  final String currency;
  final int totalEmployees;
  final int activeEmployees;
  final int inactiveEmployees;
  final int hiredThisMonth;
  final double monthlySalaryTotal;
  final double averageMonthlySalary;
  final List<EmployeesByStoreModel> byStore;
  final List<EmployeesByPositionModel> byPosition;
}
