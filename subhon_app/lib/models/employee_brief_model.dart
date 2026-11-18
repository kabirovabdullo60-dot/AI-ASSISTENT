import '../core/utils/local_date.dart';

import 'employee_status.dart';

/// `EmployeeBriefOut` from the API contract (API.md / Swagger).
class EmployeeBriefModel {
  const EmployeeBriefModel({
    required this.id,
    required this.fullName,
    required this.position,
    required this.storeId,
    required this.storeName,
    required this.status,
    required this.hiredAt,
    this.terminatedAt,
    required this.isDeleted,
  });

  factory EmployeeBriefModel.fromJson(Map<String, dynamic> json) =>
      EmployeeBriefModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        position: json['position'] as String,
        storeId: json['storeId'] as String,
        storeName: json['storeName'] as String,
        status: EmployeeStatus.fromJson(json['status'] as String),
        hiredAt: parseLocalDate(json['hiredAt'] as String),
        terminatedAt: json['terminatedAt'] == null
            ? null
            : parseLocalDate(json['terminatedAt'] as String),
        isDeleted: json['isDeleted'] as bool,
      );

  final String id;
  final String fullName;
  final String position;
  final String storeId;
  final String storeName;
  final EmployeeStatus status;
  final DateTime hiredAt;
  final DateTime? terminatedAt;
  final bool isDeleted;
}
