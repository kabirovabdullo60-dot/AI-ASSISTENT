import '../core/utils/money.dart';

import 'store_status.dart';

/// `EmployeesByStoreOut` from the API contract (API.md / Swagger).
class EmployeesByStoreModel {
  const EmployeesByStoreModel({
    required this.storeId,
    required this.storeName,
    required this.storeStatus,
    required this.storeIsDeleted,
    required this.employeesCount,
    required this.activeEmployees,
    required this.monthlySalaryTotal,
  });

  factory EmployeesByStoreModel.fromJson(Map<String, dynamic> json) =>
      EmployeesByStoreModel(
        storeId: json['storeId'] as String,
        storeName: json['storeName'] as String,
        storeStatus: StoreStatus.fromJson(json['storeStatus'] as String),
        storeIsDeleted: json['storeIsDeleted'] as bool,
        employeesCount: json['employeesCount'] as int,
        activeEmployees: json['activeEmployees'] as int,
        monthlySalaryTotal: parseMoney(json['monthlySalaryTotal'] as String),
      );

  final String storeId;
  final String storeName;
  final StoreStatus storeStatus;
  final bool storeIsDeleted;
  final int employeesCount;
  final int activeEmployees;
  final double monthlySalaryTotal;
}
