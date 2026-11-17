import '../core/utils/json.dart';

/// GET /employees
class EmployeeModel {
  const EmployeeModel({
    required this.id,
    required this.name,
    required this.role,
    required this.storeName,
    required this.shift,
    required this.isOnShift,
    required this.monthlySalary,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
    id: asString(json['id']),
    name: asString(json['name']),
    role: asString(json['role']),
    storeName: asString(json['storeName']),
    shift: asString(json['shift']),
    isOnShift: asBool(json['isOnShift']),
    monthlySalary: asDouble(json['monthlySalary']),
  );

  final String id;
  final String name;
  final String role;
  final String storeName;
  final String shift;
  final bool isOnShift;
  final double monthlySalary;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'storeName': storeName,
    'shift': shift,
    'isOnShift': isOnShift,
    'monthlySalary': monthlySalary,
  };
}
