import '../core/utils/money.dart';

import 'employee_brief_model.dart';
import 'payment_model.dart';
import 'payroll_month_model.dart';
import 'salary_change_model.dart';

/// `EmployeePayrollOut` from the API contract (API.md / Swagger).
class EmployeePayrollModel {
  const EmployeePayrollModel({
    this.currency = 'TJS',
    required this.employee,
    required this.monthlySalary,
    required this.monthsWorked,
    required this.totalDue,
    required this.totalPaid,
    required this.totalRemaining,
    required this.salaryHistory,
    required this.months,
    required this.payments,
  });

  factory EmployeePayrollModel.fromJson(Map<String, dynamic> json) =>
      EmployeePayrollModel(
        currency: (json['currency'] ?? 'TJS') as String,
        employee: EmployeeBriefModel.fromJson(
          json['employee'] as Map<String, dynamic>,
        ),
        monthlySalary: parseMoney(json['monthlySalary'] as String),
        monthsWorked: json['monthsWorked'] as int,
        totalDue: parseMoney(json['totalDue'] as String),
        totalPaid: parseMoney(json['totalPaid'] as String),
        totalRemaining: parseMoney(json['totalRemaining'] as String),
        salaryHistory: [
          for (final e in json['salaryHistory'] as List<dynamic>)
            SalaryChangeModel.fromJson(e as Map<String, dynamic>),
        ],
        months: [
          for (final e in json['months'] as List<dynamic>)
            PayrollMonthModel.fromJson(e as Map<String, dynamic>),
        ],
        payments: [
          for (final e in json['payments'] as List<dynamic>)
            PaymentModel.fromJson(e as Map<String, dynamic>),
        ],
      );

  final String currency;
  final EmployeeBriefModel employee;
  final double monthlySalary;
  final int monthsWorked;
  final double totalDue;
  final double totalPaid;
  final double totalRemaining;
  final List<SalaryChangeModel> salaryHistory;
  final List<PayrollMonthModel> months;
  final List<PaymentModel> payments;
}
