import '../core/utils/json.dart';

/// EmployeesReportOut — GET /api/reports/employees.
class EmployeesReportModel {
  const EmployeesReportModel({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.hiredThisMonth,
    required this.monthlySalaryTotal,
    required this.averageMonthlySalary,
    required this.byStore,
    required this.byPosition,
  });

  factory EmployeesReportModel.fromJson(Map<String, dynamic> json) => EmployeesReportModel(
    totalEmployees: asInt(json['totalEmployees']),
    activeEmployees: asInt(json['activeEmployees']),
    inactiveEmployees: asInt(json['inactiveEmployees']),
    hiredThisMonth: asInt(json['hiredThisMonth']),
    monthlySalaryTotal: asDouble(json['monthlySalaryTotal']),
    averageMonthlySalary: asDouble(json['averageMonthlySalary']),
    byStore: [
      for (final r in asJsonList(json['byStore']))
        (
          storeId: asString(r['storeId']),
          storeName: asString(r['storeName']),
          employees: asInt(r['employeesCount']),
          active: asInt(r['activeEmployees']),
          salaryTotal: asDouble(r['monthlySalaryTotal']),
        ),
    ],
    byPosition: [
      for (final r in asJsonList(json['byPosition']))
        (
          position: asString(r['position']),
          employees: asInt(r['employeesCount']),
          active: asInt(r['activeEmployees']),
          salaryTotal: asDouble(r['monthlySalaryTotal']),
        ),
    ],
  );

  final int totalEmployees;
  final int activeEmployees;
  final int inactiveEmployees;
  final int hiredThisMonth;
  final double monthlySalaryTotal;
  final double averageMonthlySalary;
  final List<({String storeId, String storeName, int employees, int active, double salaryTotal})> byStore;
  final List<({String position, int employees, int active, double salaryTotal})> byPosition;

  int activeInStore(String storeId) {
    for (final r in byStore) {
      if (r.storeId == storeId) return r.active;
    }
    return 0;
  }
}
