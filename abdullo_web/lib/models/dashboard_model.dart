import '../core/utils/json.dart';

/// DashboardOut — GET /api/reports/dashboard.
class DashboardModel {
  const DashboardModel({
    required this.today,
    required this.totalStores,
    required this.activeStores,
    required this.totalEmployees,
    required this.activeEmployees,
    required this.todaySales,
    required this.todaySalesCount,
    required this.weekSales,
    required this.weekSalesCount,
    required this.monthSales,
    required this.monthSalesCount,
    required this.salaryDueThisMonth,
    required this.paidSalaryThisMonth,
    required this.remainingSalaryThisMonth,
    required this.remainingSalaryTotal,
    this.topStoreName,
    this.topStoreAmount = 0,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final top = json['topStore'] is Map ? Map<String, dynamic>.from(json['topStore'] as Map) : null;
    return DashboardModel(
      today: asDay(json['today']),
      totalStores: asInt(json['totalStores']),
      activeStores: asInt(json['activeStores']),
      totalEmployees: asInt(json['totalEmployees']),
      activeEmployees: asInt(json['activeEmployees']),
      todaySales: asDouble(json['todaySales']),
      todaySalesCount: asInt(json['todaySalesCount']),
      weekSales: asDouble(json['weekSales']),
      weekSalesCount: asInt(json['weekSalesCount']),
      monthSales: asDouble(json['monthSales']),
      monthSalesCount: asInt(json['monthSalesCount']),
      salaryDueThisMonth: asDouble(json['salaryDueThisMonth']),
      paidSalaryThisMonth: asDouble(json['paidSalaryThisMonth']),
      remainingSalaryThisMonth: asDouble(json['remainingSalaryThisMonth']),
      remainingSalaryTotal: asDouble(json['remainingSalaryTotal']),
      topStoreName: top == null ? null : asString(top['storeName']),
      topStoreAmount: top == null ? 0 : asDouble(top['totalAmount']),
    );
  }

  final DateTime today;
  final int totalStores;
  final int activeStores;
  final int totalEmployees;
  final int activeEmployees;
  final double todaySales;
  final int todaySalesCount;
  final double weekSales;
  final int weekSalesCount;
  final double monthSales;
  final int monthSalesCount;
  final double salaryDueThisMonth;
  final double paidSalaryThisMonth;
  final double remainingSalaryThisMonth;
  final double remainingSalaryTotal;
  final String? topStoreName;
  final double topStoreAmount;
}
