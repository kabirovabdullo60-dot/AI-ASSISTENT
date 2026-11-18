import '../core/utils/local_date.dart';
import '../core/utils/money.dart';

import 'employee_status.dart';

/// `EmployeeBalanceRow` from the API contract (API.md / Swagger).
class EmployeeBalanceRowModel {
  const EmployeeBalanceRowModel({
    required this.employeeId,
    required this.fullName,
    required this.position,
    required this.storeId,
    required this.storeName,
    required this.employeeStatus,
    required this.isDeleted,
    required this.hiredAt,
    this.terminatedAt,
    required this.monthsWorked,
    required this.monthlySalary,
    required this.totalDue,
    required this.totalPaid,
    required this.totalRemaining,
    required this.unpaidMonths,
  });

  factory EmployeeBalanceRowModel.fromJson(Map<String, dynamic> json) =>
      EmployeeBalanceRowModel(
        employeeId: json['employeeId'] as String,
        fullName: json['fullName'] as String,
        position: json['position'] as String,
        storeId: json['storeId'] as String,
        storeName: json['storeName'] as String,
        employeeStatus: EmployeeStatus.fromJson(
          json['employeeStatus'] as String,
        ),
        isDeleted: json['isDeleted'] as bool,
        hiredAt: parseLocalDate(json['hiredAt'] as String),
        terminatedAt: json['terminatedAt'] == null
            ? null
            : parseLocalDate(json['terminatedAt'] as String),
        monthsWorked: json['monthsWorked'] as int,
        monthlySalary: parseMoney(json['monthlySalary'] as String),
        totalDue: parseMoney(json['totalDue'] as String),
        totalPaid: parseMoney(json['totalPaid'] as String),
        totalRemaining: parseMoney(json['totalRemaining'] as String),
        unpaidMonths: json['unpaidMonths'] as int,
      );

  final String employeeId;
  final String fullName;
  final String position;
  final String storeId;
  final String storeName;
  final EmployeeStatus employeeStatus;
  final bool isDeleted;
  final DateTime hiredAt;
  final DateTime? terminatedAt;
  final int monthsWorked;
  final double monthlySalary;
  final double totalDue;
  final double totalPaid;
  final double totalRemaining;
  final int unpaidMonths;
}
