import '../core/utils/json.dart';
import 'chart_point_model.dart';

/// GET /dashboard/overview — everything on the "Business Overview" page.
/// All money is in TJS.
class OverviewModel {
  const OverviewModel({
    required this.totalStores,
    required this.activeStores,
    required this.newStoresThisQuarter,
    required this.totalStaff,
    required this.staffOnShift,
    required this.todaySales,
    required this.todayChange,
    required this.weeklySales,
    required this.weeklyChange,
    required this.weeklyTarget,
    required this.monthlySales,
    required this.monthlyChange,
    required this.unpaidSalaries,
    required this.pendingPayrolls,
    required this.payrollCycle,
    required this.grossMargin,
    required this.onlineShare,
    required this.cashInVaults,
    required this.averageDaily,
    required this.totalTransactions,
    required this.reconciliationRate,
    required this.dailyRevenue,
  });

  factory OverviewModel.fromJson(Map<String, dynamic> json) => OverviewModel(
    totalStores: asInt(json['totalStores']),
    activeStores: asInt(json['activeStores']),
    newStoresThisQuarter: asInt(json['newStoresThisQuarter']),
    totalStaff: asInt(json['totalStaff']),
    staffOnShift: asInt(json['staffOnShift']),
    todaySales: asDouble(json['todaySales']),
    todayChange: asDouble(json['todayChange']),
    weeklySales: asDouble(json['weeklySales']),
    weeklyChange: asDouble(json['weeklyChange']),
    weeklyTarget: asDouble(json['weeklyTarget']),
    monthlySales: asDouble(json['monthlySales']),
    monthlyChange: asDouble(json['monthlyChange']),
    unpaidSalaries: asDouble(json['unpaidSalaries']),
    pendingPayrolls: asInt(json['pendingPayrolls']),
    payrollCycle: asString(json['payrollCycle']),
    grossMargin: asDouble(json['grossMargin']),
    onlineShare: asDouble(json['onlineShare']),
    cashInVaults: asDouble(json['cashInVaults']),
    averageDaily: asDouble(json['averageDaily']),
    totalTransactions: asInt(json['totalTransactions']),
    reconciliationRate: asDouble(json['reconciliationRate']),
    dailyRevenue: asJsonList(json['dailyRevenue']).map(ChartPointModel.fromJson).toList(),
  );

  final int totalStores;
  final int activeStores;
  final int newStoresThisQuarter;
  final int totalStaff;
  final int staffOnShift;
  final double todaySales;
  final double todayChange;
  final double weeklySales;
  final double weeklyChange;
  final double weeklyTarget;
  final double monthlySales;
  final double monthlyChange;
  final double unpaidSalaries;
  final int pendingPayrolls;
  final String payrollCycle;
  final double grossMargin;
  final double onlineShare;
  final double cashInVaults;
  final double averageDaily;
  final int totalTransactions;
  final double reconciliationRate;
  final List<ChartPointModel> dailyRevenue;

  Map<String, dynamic> toJson() => {
    'totalStores': totalStores,
    'activeStores': activeStores,
    'newStoresThisQuarter': newStoresThisQuarter,
    'totalStaff': totalStaff,
    'staffOnShift': staffOnShift,
    'todaySales': todaySales,
    'todayChange': todayChange,
    'weeklySales': weeklySales,
    'weeklyChange': weeklyChange,
    'weeklyTarget': weeklyTarget,
    'monthlySales': monthlySales,
    'monthlyChange': monthlyChange,
    'unpaidSalaries': unpaidSalaries,
    'pendingPayrolls': pendingPayrolls,
    'payrollCycle': payrollCycle,
    'grossMargin': grossMargin,
    'onlineShare': onlineShare,
    'cashInVaults': cashInVaults,
    'averageDaily': averageDaily,
    'totalTransactions': totalTransactions,
    'reconciliationRate': reconciliationRate,
    'dailyRevenue': dailyRevenue.map((e) => e.toJson()).toList(),
  };
}
