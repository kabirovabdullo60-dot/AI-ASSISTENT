import '../core/utils/local_date.dart';
import '../core/utils/money.dart';

import 'employee_status.dart';

/// `EmployeeOut` from the API contract (API.md / Swagger).
class EmployeeModel {
  const EmployeeModel({
    required this.id,
    required this.fullName,
    this.phone,
    required this.position,
    required this.storeId,
    required this.storeName,
    required this.monthlySalary,
    required this.hiredAt,
    this.terminatedAt,
    required this.status,
    required this.monthsWorked,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    phone: json['phone'] as String?,
    position: json['position'] as String,
    storeId: json['storeId'] as String,
    storeName: json['storeName'] as String,
    monthlySalary: parseMoney(json['monthlySalary'] as String),
    hiredAt: parseLocalDate(json['hiredAt'] as String),
    terminatedAt: json['terminatedAt'] == null
        ? null
        : parseLocalDate(json['terminatedAt'] as String),
    status: EmployeeStatus.fromJson(json['status'] as String),
    monthsWorked: json['monthsWorked'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    deletedAt: json['deletedAt'] == null
        ? null
        : DateTime.parse(json['deletedAt'] as String).toLocal(),
  );

  final String id;
  final String fullName;
  final String? phone;
  final String position;
  final String storeId;
  final String storeName;
  final double monthlySalary;
  final DateTime hiredAt;
  final DateTime? terminatedAt;
  final EmployeeStatus status;
  final int monthsWorked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
}
