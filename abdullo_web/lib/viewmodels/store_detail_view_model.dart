import '../core/utils/format.dart';
import '../models/chart_point_model.dart';
import '../models/employee_model.dart';
import '../models/sale_model.dart';
import '../services/employee_service.dart';
import '../services/sales_service.dart';
import 'base_view_model.dart';

/// Data for the "View Analytics" side panel of one store.
class StoreDetailViewModel extends BaseViewModel {
  StoreDetailViewModel(this._sales, this._employees, this.storeId);

  final SalesService _sales;
  final EmployeeService _employees;
  final String storeId;

  List<ChartPointModel>? _last7;
  List<SaleModel> _recent = const [];
  List<EmployeeModel> _staff = const [];

  List<ChartPointModel>? get last7Days => _last7;
  List<SaleModel> get recent => _recent;
  List<EmployeeModel> get staff => _staff;

  double get average =>
      (_last7 == null || _last7!.isEmpty) ? 0 : _last7!.fold<double>(0, (s, p) => s + p.revenue) / _last7!.length;

  Future<void> load() => runTask(() async {
    final today = dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 6));
    final (week, recent, staff) = await (
      _sales.list(storeId: storeId, startDate: start, endDate: today, limit: 100),
      _sales.list(storeId: storeId, limit: 5, sort: '-createdAt'),
      _employees.fetchAll(storeId: storeId),
    ).wait;
    _last7 = [
      for (var i = 0; i < 7; i++)
        () {
          final day = start.add(Duration(days: i));
          final items = week.items.where((s) => isSameDay(s.saleDate, day));
          return ChartPointModel(
            date: day,
            revenue: items.fold<double>(0, (sum, s) => sum + s.amount),
            count: items.length,
          );
        }(),
    ];
    _recent = recent.items;
    _staff = staff;
  });
}
