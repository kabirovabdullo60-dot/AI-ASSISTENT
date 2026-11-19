import '../core/utils/json.dart';
import 'store_model.dart' show cleanPhone;

/// EmployeeOut — GET /api/employees.
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
    this.isActive = true,
    this.monthsWorked = 0,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
    id: asString(json['id']),
    fullName: asString(json['fullName']),
    phone: json['phone'] == null ? null : asString(json['phone']),
    position: asString(json['position']),
    storeId: asString(json['storeId']),
    storeName: asString(json['storeName']),
    monthlySalary: asDouble(json['monthlySalary']),
    hiredAt: asDay(json['hiredAt']),
    terminatedAt: asDayOrNull(json['terminatedAt']),
    isActive: asString(json['status'], 'ACTIVE') == 'ACTIVE',
    monthsWorked: asInt(json['monthsWorked']),
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
  final bool isActive;
  final int monthsWorked;

  /// Body for POST /api/employees and PUT /api/employees/{id}.
  Map<String, dynamic> toJson() => {
    'fullName': fullName.trim(),
    'phone': cleanPhone(phone),
    'position': position.trim(),
    'storeId': storeId,
    'monthlySalary': money(monthlySalary),
    'hiredAt': isoDay(hiredAt),
    'terminatedAt': terminatedAt == null ? null : isoDay(terminatedAt!),
    'status': isActive ? 'ACTIVE' : 'INACTIVE',
  };
}
