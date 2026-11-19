import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';
import '../models/sales_report_model.dart';
import '../models/store_comparison_model.dart';
import '../models/target_period.dart';
import '../models/target_put_model.dart';
import '../services/reports_service.dart';
import '../services/sales_service.dart';
import '../services/target_service.dart';
import 'sales_period.dart';

/// Home: the business dashboard, sales of the chosen period (today / week /
/// month, compared with the previous one), the top stores, this month's
/// profit and the business-wide sales targets.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._reports, this._sales, this._targets);

  final ReportsService _reports;
  final SalesService _sales;
  final TargetService _targets;

  DashboardModel? _dashboard;
  SalesReportModel? _periodReport;
  StoreComparisonModel? _topStores;
  SalesPeriod _period = SalesPeriod.today;
  bool _isLoading = false;
  bool _isPeriodLoading = false;
  Object? _error;

  DashboardModel? get dashboard => _dashboard;
  SalesReportModel? get periodReport => _periodReport;
  StoreComparisonModel? get topStores => _topStores;
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

  /// Sets the business-wide [period] target (`PUT /api/targets`) and reloads
  /// the dashboard; the error, if any, is returned (not shown as the page
  /// error).
  Future<ApiException?> setTarget(TargetPeriod period, double amount) async {
    try {
      await _targets.put(TargetPutModel(period: period, amount: amount));
      _dashboard = await _reports.dashboard();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e;
    }
  }

  Future<SalesReportModel> _report(SalesPeriod period) => switch (period) {
    SalesPeriod.today => _sales.daily(),
    SalesPeriod.week => _sales.weekly(),
    SalesPeriod.month => _reports.monthlySales(),
  };
}
