import '../core/utils/local_date.dart';

import 'employee_status.dart';

/// `EmployeeUpdate` from the API contract (API.md / Swagger).
class EmployeeUpdateModel {
  const EmployeeUpdateModel({
    this.fullName,
    this.phone,
    this.position,
    this.storeId,
    this.monthlySalary,
    this.hiredAt,
    this.terminatedAt,
    this.status,
  });

  final String? fullName;
  final String? phone;
  final String? position;
  final String? storeId;
  final double? monthlySalary;
  final DateTime? hiredAt;
  final DateTime? terminatedAt;
  final EmployeeStatus? status;

  /// Fields sent as `null` to clear them (optional fields only).
  static const clearable = {'phone', 'terminatedAt'};

  /// PUT updates only the fields that are sent: a field left `null`
  /// is not sent, unless it is listed in [clear] (then it is cleared).
  Map<String, dynamic> toJson({Set<String> clear = const {}}) => {
    'fullName': ?fullName,
    if (phone != null || clear.contains('phone')) 'phone': phone,
    'position': ?position,
    'storeId': ?storeId,
    if (monthlySalary != null)
      'monthlySalary': monthlySalary!.toStringAsFixed(2),
    if (hiredAt != null) 'hiredAt': formatLocalDate(hiredAt!),
    if (terminatedAt != null || clear.contains('terminatedAt'))
      'terminatedAt': terminatedAt == null
          ? null
          : formatLocalDate(terminatedAt!),
    if (status != null) 'status': status!.json,
  };
}
