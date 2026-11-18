import '../core/utils/local_date.dart';

import 'employee_status.dart';

/// `EmployeeCreate` from the API contract (API.md / Swagger).
class EmployeeCreateModel {
  const EmployeeCreateModel({
    required this.fullName,
    this.phone,
    required this.position,
    required this.storeId,
    required this.monthlySalary,
    required this.hiredAt,
    this.terminatedAt,
    this.status = EmployeeStatus.active,
  });

  final String fullName;
  final String? phone;
  final String position;
  final String storeId;
  final double monthlySalary;
  final DateTime hiredAt;
  final DateTime? terminatedAt;
  final EmployeeStatus status;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': ?phone,
    'position': position,
    'storeId': storeId,
    'monthlySalary': monthlySalary.toStringAsFixed(2),
    'hiredAt': formatLocalDate(hiredAt),
    if (terminatedAt != null) 'terminatedAt': formatLocalDate(terminatedAt!),
    'status': status.json,
  };
}
