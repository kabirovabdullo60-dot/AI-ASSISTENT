import '../core/utils/json.dart';

/// One salary payment (GET /payroll/disbursements, POST /payroll/{id}/payments).
class DisbursementModel {
  const DisbursementModel({
    required this.id,
    required this.payrollId,
    required this.employeeName,
    required this.amount,
    required this.method,
    required this.reference,
    required this.time,
    this.part = '',
  });

  factory DisbursementModel.fromJson(Map<String, dynamic> json) => DisbursementModel(
    id: asString(json['id']),
    payrollId: asString(json['payrollId']),
    employeeName: asString(json['employeeName']),
    amount: asDouble(json['amount']),
    method: asString(json['method']),
    reference: asString(json['reference']),
    time: asDate(json['time']),
    part: asString(json['part']),
  );

  final String id;
  final String payrollId;
  final String employeeName;
  final double amount;

  /// "Bank Transfer", "Cash Disbursement"
  final String method;

  /// "#PAY-9921"
  final String reference;
  final DateTime time;

  /// "Part 1 of 2" for partial payments, otherwise empty.
  final String part;

  Map<String, dynamic> toJson() => {
    'id': id,
    'payrollId': payrollId,
    'employeeName': employeeName,
    'amount': amount,
    'method': method,
    'reference': reference,
    'time': time.toIso8601String(),
    'part': part,
  };
}
