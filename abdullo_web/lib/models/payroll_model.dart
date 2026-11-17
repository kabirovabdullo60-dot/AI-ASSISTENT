import '../core/utils/json.dart';

enum PayStatus {
  paid('Paid'),
  partial('Partial'),
  unpaid('Unpaid');

  const PayStatus(this.label);
  final String label;
}

/// GET /payroll?period= — one employee's salary for one month.
class PayrollModel {
  const PayrollModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.role,
    required this.storeName,
    required this.tenureMonths,
    required this.salary,
    required this.disbursed,
    required this.period,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) => PayrollModel(
    id: asString(json['id']),
    employeeId: asString(json['employeeId']),
    employeeName: asString(json['employeeName']),
    role: asString(json['role']),
    storeName: asString(json['storeName']),
    tenureMonths: asInt(json['tenureMonths']),
    salary: asDouble(json['salary']),
    disbursed: asDouble(json['disbursed']),
    period: asString(json['period']),
  );

  final String id;
  final String employeeId;
  final String employeeName;
  final String role;
  final String storeName;
  final int tenureMonths;
  final double salary;
  final double disbursed;

  /// "2026-11"
  final String period;

  double get remaining => (salary - disbursed).clamp(0, salary).toDouble();

  PayStatus get status => remaining <= 0
      ? PayStatus.paid
      : disbursed > 0
      ? PayStatus.partial
      : PayStatus.unpaid;

  PayrollModel copyWith({double? disbursed}) => PayrollModel(
    id: id,
    employeeId: employeeId,
    employeeName: employeeName,
    role: role,
    storeName: storeName,
    tenureMonths: tenureMonths,
    salary: salary,
    disbursed: disbursed ?? this.disbursed,
    period: period,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'employeeName': employeeName,
    'role': role,
    'storeName': storeName,
    'tenureMonths': tenureMonths,
    'salary': salary,
    'disbursed': disbursed,
    'period': period,
  };
}
