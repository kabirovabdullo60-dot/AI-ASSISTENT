import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/activity_model.dart';
import '../models/dashboard_model.dart';
import '../models/sales_report_model.dart';
import '../models/store_comparison_model.dart';
import '../models/store_model.dart';
import '../services/activity_service.dart';
import '../services/reports_service.dart';
import '../services/sales_service.dart';
import '../services/store_service.dart';
import 'sales_period.dart';

/// Home: the business dashboard (incl. this month's profit), sales of the
/// chosen period (today / week / month, compared with the previous one),
/// the stores, the top stores and the latest changes.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._reports, this._sales, this._stores, this._activity);

  final ReportsService _reports;
  final SalesService _sales;
  final StoreService _stores;
  final ActivityService _activity;

  DashboardModel? _dashboard;
  SalesReportModel? _periodReport;
  StoreComparisonModel? _topStores;
  List<ActivityModel>? _recent;
  List<StoreModel>? _storeList;
  SalesPeriod _period = SalesPeriod.today;
  bool _isLoading = false;
  bool _isPeriodLoading = false;
  Object? _error;

  DashboardModel? get dashboard => _dashboard;
  SalesReportModel? get periodReport => _periodReport;
  StoreComparisonModel? get topStores => _topStores;

  /// The latest changes (5); `null` when they could not be loaded (the
  /// rest of the dashboard still shows).
  List<ActivityModel>? get recentActivity => _recent;

  /// All stores for the strip on home; `null` when they could not be
  /// loaded (the rest still shows).
  List<StoreModel>? get stores => _storeList;
  SalesPeriod get period => _period;
  bool get isLoading => _isLoading;
  bool get isPeriodLoading => _isPeriodLoading;
  bool get hasData => _dashboard != null;
  Object? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _reports.dashboard(),
        _report(_period),
        _reports.storeComparison(),
      ]);
      _dashboard = results[0] as DashboardModel;
      _periodReport = results[1] as SalesReportModel;
      _topStores = results[2] as StoreComparisonModel;
      try {
        _recent = (await _activity.list(limit: 5)).items;
      } on ApiException {
        _recent = null;
      }
      try {
        _storeList = (await _stores.list(limit: 100)).items;
      } on ApiException {
        _storeList = null;
      }
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPeriod(SalesPeriod period) async {
    if (period == _period) return;
    _period = period;
    _isPeriodLoading = true;
    notifyListeners();
    try {
      _periodReport = await _report(period);
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isPeriodLoading = false;
      notifyListeners();
    }
  }

  Future<SalesReportModel> _report(SalesPeriod period) => switch (period) {
    SalesPeriod.today => _sales.daily(),
    SalesPeriod.week => _sales.weekly(),
    SalesPeriod.month => _reports.monthlySales(),
  };
}
