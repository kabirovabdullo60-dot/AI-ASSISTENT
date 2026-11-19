import '../core/utils/local_date.dart';
import '../core/utils/money.dart';

import 'payroll_status.dart';
import 'period_balance_model.dart';
import 'salary_payment_method.dart';

/// `PaymentOut` from the API contract (API.md / Swagger).
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
    this.method,
    required this.period,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'] as String,
    employeeId: json['employeeId'] as String,
    employeeName: json['employeeName'] as String,
    amount: parseMoney(json['amount'] as String),
    month: json['month'] as int,
    year: json['year'] as int,
    paymentDate: parseLocalDate(json['paymentDate'] as String),
    status: PayrollStatus.fromJson(json['status'] as String),
    note: json['note'] as String?,
    method: SalaryPaymentMethod.fromJson(json['method'] as String?),
    period: PeriodBalanceModel.fromJson(json['period'] as Map<String, dynamic>),
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
  );

  final String id;
  final String employeeId;
  final String employeeName;
  final double amount;
  final int month;
  final int year;
  final DateTime paymentDate;
  final PayrollStatus status;
  final String? note;

  /// How it was paid; `null` when not recorded.
  final SalaryPaymentMethod? method;
  final PeriodBalanceModel period;
  final DateTime createdAt;
}
