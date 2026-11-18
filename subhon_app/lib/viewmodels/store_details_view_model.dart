import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/employee_model.dart';
import '../models/page_model.dart';
import '../models/sale_model.dart';
import '../models/store_model.dart';
import '../services/employee_service.dart';
import '../services/sales_service.dart';
import '../services/store_service.dart';

/// One store with its latest sales and its employees.
class StoreDetailsViewModel extends ChangeNotifier {
  StoreDetailsViewModel(
    this._stores,
    this._sales,
    this._employees,
    this.storeId,
  );

  final StoreService _stores;
  final SalesService _sales;
  final EmployeeService _employees;
  final String storeId;

  StoreModel? _store;
  PageModel<SaleModel>? _salesPage;
  PageModel<EmployeeModel>? _staff;
  bool _isLoading = false;
  Object? _error;

  StoreModel? get store => _store;
  PageModel<SaleModel>? get sales => _salesPage;
  PageModel<EmployeeModel>? get employees => _staff;
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
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Soft delete; refused with `STORE_HAS_ACTIVE_EMPLOYEES` (thrown).
  Future<void> delete() => _stores.delete(storeId);
}
