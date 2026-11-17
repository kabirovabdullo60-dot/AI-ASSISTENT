import '../core/utils/json.dart';

enum PayStatus {
  paid,
  partial,
  unpaid;

  static PayStatus parse(Object? v) => switch ('$v') {
    'PAID' => PayStatus.paid,
    'PARTIAL' => PayStatus.partial,
    _ => PayStatus.unpaid,
  };
}

/// MonthlyPayrollRow — one employee in GET /api/payroll/monthly.
class PayrollModel {
  const PayrollModel({
    required this.employeeId,
    required this.employeeName,
    required this.role,
    required this.storeId,
    required this.storeName,
    required this.monthlySalary,
    required this.workedDays,
    required this.salary,
    required this.disbursed,
    required this.remaining,
    required this.status,
    this.paymentsCount = 0,
    this.employeeActive = true,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) => PayrollModel(
    employeeId: asString(json['employeeId']),
    employeeName: asString(json['fullName']),
    role: asString(json['position']),
    storeId: asString(json['storeId']),
    storeName: asString(json['storeName']),
    monthlySalary: asDouble(json['monthlySalary']),
    workedDays: asInt(json['workedDays']),
    salary: asDouble(json['dueAmount']),
    disbursed: asDouble(json['paidAmount']),
    remaining: asDouble(json['remainingAmount']),
    status: PayStatus.parse(json['status']),
    paymentsCount: asInt(json['paymentsCount']),
    employeeActive: asString(json['employeeStatus'], 'ACTIVE') == 'ACTIVE',
  );

  /// Used as row id (one row per employee per month).
  String get id => employeeId;
  final String employeeId;
  final String employeeName;
  final String role;
  final String storeId;
  final String storeName;
  final double monthlySalary;
  final int workedDays;

  /// Due for this month (the backend prorates partial months).
  final double salary;
  final double disbursed;
  final double remaining;
  final PayStatus status;
  final int paymentsCount;
  final bool employeeActive;
}

/// MonthlyPayrollOut — GET /api/payroll/monthly?month=&year=.
class MonthlyPayrollModel {
  const MonthlyPayrollModel({
    required this.year,
    required this.month,
    required this.totalDue,
    required this.totalPaid,
    required this.totalRemaining,
    required this.items,
  });

  factory MonthlyPayrollModel.fromJson(Map<String, dynamic> json) => MonthlyPayrollModel(
    year: asInt(json['year']),
    month: asInt(json['month']),
    totalDue: asDouble(json['totalDue']),
    totalPaid: asDouble(json['totalPaid']),
    totalRemaining: asDouble(json['totalRemaining']),
    items: asJsonList(json['items']).map(PayrollModel.fromJson).toList(),
  );

  final int year;
  final int month;
  final double totalDue;
  final double totalPaid;
  final double totalRemaining;
  final List<PayrollModel> items;
}
