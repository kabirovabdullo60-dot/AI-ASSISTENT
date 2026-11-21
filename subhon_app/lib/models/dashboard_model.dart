import '../core/utils/local_date.dart';
import '../core/utils/money.dart';

import 'top_store_model.dart';

/// `DashboardOut` from the API contract (API.md / Swagger).
class DashboardModel {
  const DashboardModel({
    this.currency = 'TJS',
    required this.today,
    required this.weekStartDate,
    required this.year,
    required this.month,
    required this.totalStores,
    required this.activeStores,
    required this.inactiveStores,
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
    this.topStore,
    this.monthExpenses = 0,
    this.monthProfit = 0,
    this.monthMarginPercent,
    this.weekTarget,
    this.monthTarget,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    currency: (json['currency'] ?? 'TJS') as String,
    today: parseLocalDate(json['today'] as String),
    weekStartDate: parseLocalDate(json['weekStartDate'] as String),
    year: json['year'] as int,
    month: json['month'] as int,
    totalStores: json['totalStores'] as int,
    activeStores: json['activeStores'] as int,
    inactiveStores: json['inactiveStores'] as int,
    totalEmployees: json['totalEmployees'] as int,
    activeEmployees: json['activeEmployees'] as int,
    todaySales: parseMoney(json['todaySales'] as String),
    todaySalesCount: json['todaySalesCount'] as int,
    weekSales: parseMoney(json['weekSales'] as String),
    weekSalesCount: json['weekSalesCount'] as int,
    monthSales: parseMoney(json['monthSales'] as String),
    monthSalesCount: json['monthSalesCount'] as int,
    salaryDueThisMonth: parseMoney(json['salaryDueThisMonth'] as String),
    paidSalaryThisMonth: parseMoney(json['paidSalaryThisMonth'] as String),
    remainingSalaryThisMonth: parseMoney(
      json['remainingSalaryThisMonth'] as String,
    ),
    remainingSalaryTotal: parseMoney(json['remainingSalaryTotal'] as String),
    topStore: json['topStore'] == null
        ? null
        : TopStoreModel.fromJson(json['topStore'] as Map<String, dynamic>),
    monthExpenses: parseMoney((json['monthExpenses'] ?? '0.00') as String),
    monthProfit: parseMoney((json['monthProfit'] ?? '0.00') as String),
    monthMarginPercent: (json['monthMarginPercent'] as num?)?.toDouble(),
    weekTarget: json['weekTarget'] == null
        ? null
        : parseMoney(json['weekTarget'] as String),
    monthTarget: json['monthTarget'] == null
        ? null
        : parseMoney(json['monthTarget'] as String),
  );

  final String currency;
  final DateTime today;
  final DateTime weekStartDate;
  final int year;
  final int month;
  final int totalStores;
  final int activeStores;
  final int inactiveStores;
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
  final TopStoreModel? topStore;

  /// Expenses this month.
  final double monthExpenses;

  /// This month's sales − expenses − salary due (may be negative).
  final double monthProfit;

  /// `null` without sales.
  final double? monthMarginPercent;

  /// Business-wide sales targets; `null` when not set.
  final double? weekTarget;
  final double? monthTarget;
}
