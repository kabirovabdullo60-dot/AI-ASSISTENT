import '../core/utils/money.dart';

import 'employee_status.dart';
import 'payroll_status.dart';

/// `MonthlyPayrollRow` from the API contract (API.md / Swagger).
class MonthlyPayrollRowModel {
  const MonthlyPayrollRowModel({
    required this.employeeId,
    required this.fullName,
    required this.position,
    required this.storeId,
    required this.storeName,
    required this.employeeStatus,
    required this.isDeleted,
    required this.monthlySalary,
    required this.workedDays,
    required this.dueAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.paymentsCount,
  });

  factory MonthlyPayrollRowModel.fromJson(Map<String, dynamic> json) =>
      MonthlyPayrollRowModel(
        employeeId: json['employeeId'] as String,
        fullName: json['fullName'] as String,
        position: json['position'] as String,
        storeId: json['storeId'] as String,
        storeName: json['storeName'] as String,
        employeeStatus: EmployeeStatus.fromJson(
          json['employeeStatus'] as String,
        ),
        isDeleted: json['isDeleted'] as bool,
        monthlySalary: parseMoney(json['monthlySalary'] as String),
        workedDays: json['workedDays'] as int,
        dueAmount: parseMoney(json['dueAmount'] as String),
        paidAmount: parseMoney(json['paidAmount'] as String),
        remainingAmount: parseMoney(json['remainingAmount'] as String),
        status: PayrollStatus.fromJson(json['status'] as String),
        paymentsCount: json['paymentsCount'] as int,
      );

  final String employeeId;
  final String fullName;
  final String position;
  final String storeId;
  final String storeName;
  final EmployeeStatus employeeStatus;
  final bool isDeleted;
  final double monthlySalary;
  final int workedDays;
  final double dueAmount;
  final double paidAmount;
  final double remainingAmount;
  final PayrollStatus status;
  final int paymentsCount;
}
