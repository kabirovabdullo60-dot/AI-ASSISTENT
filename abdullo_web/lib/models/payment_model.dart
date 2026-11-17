import '../core/utils/json.dart';
import 'payroll_model.dart';

/// PaymentOut — one salary payment (POST/GET /api/payroll).
class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.month,
    required this.year,
    required this.paymentDate,
    required this.status,
    this.note,
    this.periodRemaining = 0,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final period = json['period'] is Map ? Map<String, dynamic>.from(json['period'] as Map) : const {};
    return PaymentModel(
      id: asString(json['id']),
      employeeId: asString(json['employeeId']),
      employeeName: asString(json['employeeName']),
      amount: asDouble(json['amount']),
      month: asInt(json['month']),
      year: asInt(json['year']),
      paymentDate: asDay(json['paymentDate']),
      status: PayStatus.parse(json['status']),
      note: json['note'] == null ? null : asString(json['note']),
      periodRemaining: asDouble(period['remainingAmount']),
      createdAt: json['createdAt'] == null ? null : asDate(json['createdAt']),
    );
  }

  final String id;
  final String employeeId;
  final String employeeName;
  final double amount;
  final int month;
  final int year;
  final DateTime paymentDate;

  /// Status of that month after this payment.
  final PayStatus status;
  final String? note;
  final double periodRemaining;
  final DateTime? createdAt;
}

/// EmployeePayrollOut — GET /api/payroll/employee/{id}: all months and payments of one employee.
class EmployeePayrollModel {
  const EmployeePayrollModel({
    required this.employeeName,
    required this.monthlySalary,
    required this.monthsWorked,
    required this.totalDue,
    required this.totalPaid,
    required this.totalRemaining,
    required this.months,
    required this.payments,
  });

  factory EmployeePayrollModel.fromJson(Map<String, dynamic> json) {
    final e = json['employee'] is Map ? Map<String, dynamic>.from(json['employee'] as Map) : const {};
    return EmployeePayrollModel(
      employeeName: asString(e['fullName']),
      monthlySalary: asDouble(json['monthlySalary']),
      monthsWorked: asInt(json['monthsWorked']),
      totalDue: asDouble(json['totalDue']),
      totalPaid: asDouble(json['totalPaid']),
      totalRemaining: asDouble(json['totalRemaining']),
      months: [
        for (final m in asJsonList(json['months']))
          (
            year: asInt(m['year']),
            month: asInt(m['month']),
            due: asDouble(m['dueAmount']),
            paid: asDouble(m['paidAmount']),
            remaining: asDouble(m['remainingAmount']),
            status: PayStatus.parse(m['status']),
          ),
      ],
      payments: asJsonList(json['payments']).map(PaymentModel.fromJson).toList(),
    );
  }

  final String employeeName;
  final double monthlySalary;
  final int monthsWorked;
  final double totalDue;
  final double totalPaid;
  final double totalRemaining;
  final List<({int year, int month, double due, double paid, double remaining, PayStatus status})> months;
  final List<PaymentModel> payments;
}

/// PayrollYearOut — GET /api/reports/payroll?year=.
class PayrollYearModel {
  const PayrollYearModel({
    required this.year,
    required this.totalDue,
    required this.totalPaid,
    required this.totalRemaining,
    required this.months,
  });

  factory PayrollYearModel.fromJson(Map<String, dynamic> json) => PayrollYearModel(
    year: asInt(json['year']),
    totalDue: asDouble(json['totalDue']),
    totalPaid: asDouble(json['totalPaid']),
    totalRemaining: asDouble(json['totalRemaining']),
    months: [
      for (final m in asJsonList(json['months']))
        (
          month: asInt(m['month']),
          due: asDouble(m['dueAmount']),
          paid: asDouble(m['paidAmount']),
          remaining: asDouble(m['remainingAmount']),
          employees: asInt(m['employeesCount']),
        ),
    ],
  );

  final int year;
  final double totalDue;
  final double totalPaid;
  final double totalRemaining;
  final List<({int month, double due, double paid, double remaining, int employees})> months;
}
