import 'package:flutter/foundation.dart';

import '../models/dashboard_model.dart';
import '../models/sales_point_model.dart';
import '../services/dashboard_service.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._service);

  final DashboardService _service;

  bool _isLoading = false;
  String? _error;
  DashboardModel? _data;
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardModel? get data => _data;

  List<SalesPointModel> get sales => _data?.sales ?? const [];

  double get totalSales => sales.fold(0, (sum, p) => sum + p.value);

  double get averageSales => sales.isEmpty ? 0 : totalSales / sales.length;

  SalesPointModel? get bestMonth => sales.isEmpty ? null : sales.reduce((a, b) => b.value > a.value ? b : a);

  /// Percent change of month [index] vs the month before. `null` for the first one.
  double? changeAt(int index) {
    if (index <= 0 || index >= sales.length) return null;
    final prev = sales[index - 1].value;
    if (prev == 0) return null;
    return (sales[index].value - prev) / prev * 100;
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    _notify();
    try {
      _data = await _service.fetchDashboard();
    } catch (e) {
      _error = 'Could not load the dashboard. Check the connection and try again.';
      debugPrint('DashboardViewModel.load: $e');
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
