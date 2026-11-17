import '../core/utils/json.dart';

/// GET /payroll — one salary in the current cycle.
class PayrollModel {
  const PayrollModel({
    required this.id,
    required this.employeeName,
    required this.role,
    required this.storeName,
    required this.amount,
    required this.period,
    required this.isPaid,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) => PayrollModel(
    id: asString(json['id']),
    employeeName: asString(json['employeeName']),
    role: asString(json['role']),
    storeName: asString(json['storeName']),
    amount: asDouble(json['amount']),
    period: asString(json['period']),
    isPaid: asBool(json['isPaid']),
  );

  final String id;
  final String employeeName;
  final String role;
  final String storeName;
  final double amount;
  final String period;
  final bool isPaid;

  PayrollModel copyWith({bool? isPaid}) => PayrollModel(
    id: id,
    employeeName: employeeName,
    role: role,
    storeName: storeName,
    amount: amount,
    period: period,
    isPaid: isPaid ?? this.isPaid,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeName': employeeName,
    'role': role,
    'storeName': storeName,
    'amount': amount,
    'period': period,
    'isPaid': isPaid,
  };
}
