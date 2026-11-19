import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/activity_model.dart';
import '../models/employee_model.dart';
import '../models/page_model.dart';
import '../models/sale_model.dart';
import '../models/sales_report_model.dart';
import '../models/store_model.dart';
import '../models/target_period.dart';
import '../models/target_put_model.dart';
import '../services/activity_service.dart';
import '../services/employee_service.dart';
import '../services/reports_service.dart';
import '../services/sales_service.dart';
import '../services/store_service.dart';
import '../services/target_service.dart';

/// One store with its latest sales, its employees, its weekly and monthly
/// sales targets and its latest operations (activity log).
class StoreDetailsViewModel extends ChangeNotifier {
  StoreDetailsViewModel(
    this._stores,
    this._sales,
    this._employees,
    this._activity,
    this._targets,
    this._reports,
    this.storeId,
  );

  final StoreService _stores;
  final SalesService _sales;
  final EmployeeService _employees;
  final ActivityService _activity;
  final TargetService _targets;
  final ReportsService _reports;
  final String storeId;

  StoreModel? _store;
  PageModel<SaleModel>? _salesPage;
  PageModel<EmployeeModel>? _staff;
  PageModel<ActivityModel>? _log;
  ({double week, double month, double? weekTarget, double? monthTarget})?
  _goals;
  bool _isLoading = false;
  Object? _error;

  StoreModel? get store => _store;
  PageModel<SaleModel>? get sales => _salesPage;
  PageModel<EmployeeModel>? get employees => _staff;

  /// The latest operations; `null` when they could not be loaded (the
  /// rest of the page still shows).
  PageModel<ActivityModel>? get log => _log;

  /// The store's sales this week / month and its targets (`null` when not
  /// set); `null` when they could not be loaded (the rest still shows).
  ({double week, double month, double? weekTarget, double? monthTarget})?
  get goals => _goals;
  bool get isLoading => _isLoading;
  bool get hasData => _store != null;
  Object? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _stores.get(storeId),
        _sales.list(storeId: storeId, limit: 10),
        _employees.list(storeId: storeId, limit: 50),
      ]);
      _store = results[0] as StoreModel;
      _salesPage = results[1] as PageModel<SaleModel>;
      _staff = results[2] as PageModel<EmployeeModel>;
      try {
        _log = await _activity.list(storeId: storeId, limit: 5);
      } on ApiException {
        _log = null;
      }
      await _loadGoals();
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadGoals() async {
    try {
      final (week, month, targets) = await (
        _sales.weekly(),
        _reports.monthlySales(),
        _targets.list(),
      ).wait;
      double sold(SalesReportModel report) => report.stores
          .where((s) => s.storeId == storeId)
          .fold(0, (sum, s) => sum + s.totalAmount);
      double? target(TargetPeriod period) => targets.items
          .where((t) => t.storeId == storeId && t.period == period)
          .map((t) => t.amount)
          .firstOrNull;
      _goals = (
        week: sold(week),
        month: sold(month),
        weekTarget: target(TargetPeriod.week),
        monthTarget: target(TargetPeriod.month),
      );
    } on ParallelWaitError<dynamic, dynamic> {
      _goals = null;
    } on ApiException {
      _goals = null;
    }
  }

  /// Sets this store's [period] target (`PUT /api/targets` with its
  /// `storeId`); returns the error, if any.
  Future<ApiException?> setTarget(TargetPeriod period, double amount) async {
    try {
      await _targets.put(
        TargetPutModel(period: period, amount: amount, storeId: storeId),
      );
      await _loadGoals();
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      return e;
    }
  }

  /// Soft delete; refused with `STORE_HAS_ACTIVE_EMPLOYEES` (thrown).
  Future<void> delete() => _stores.delete(storeId);
}
