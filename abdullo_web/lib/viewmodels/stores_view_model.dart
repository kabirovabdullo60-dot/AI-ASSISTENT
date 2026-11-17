import '../core/utils/format.dart';
import '../models/employees_report_model.dart';
import '../models/sales_report_model.dart';
import '../models/store_model.dart';
import '../services/reports_service.dart';
import '../services/sales_service.dart';
import '../services/store_service.dart';
import 'base_view_model.dart';

enum StoreStatusFilter { all, active, inactive }

enum StoreSort { revenue, today, name }

/// Sales numbers of one store (from the reports).
typedef StoreStats = ({
  double today,
  double week,
  double month,
  double? monthChange,
  double share,
  int rank,
  int staff,
});

class StoresViewModel extends BaseViewModel {
  StoresViewModel(this._stores, this._sales, this._reports);

  final StoreService _stores;
  final SalesService _sales;
  final ReportsService _reports;

  List<StoreModel> _list = const [];
  SalesReportModel? _today;
  SalesReportModel? _week;
  SalesReportModel? _month;
  EmployeesReportModel? _staff;
  bool _loaded = false;
  bool _isSaving = false;
  StoreStatusFilter _status = StoreStatusFilter.all;
  StoreSort _sort = StoreSort.revenue;
  bool _gridView = true;
  String _query = '';

  List<StoreModel> get stores => _list;
  bool get hasData => _loaded;
  bool get isSaving => _isSaving;
  StoreStatusFilter get statusFilter => _status;
  StoreSort get sort => _sort;
  bool get gridView => _gridView;

  int get activeCount => _list.where((s) => s.isActive).length;
  int get inactiveCount => _list.length - activeCount;
  double get operatingRatio => _list.isEmpty ? 0 : activeCount / _list.length;
  double get todayTotal => _today?.totalAmount ?? 0;
  double? get todayChange => _today?.changePercent;
  double get monthTotal => _month?.totalAmount ?? 0;
  double? get monthChange => _month?.changePercent;
  int get workforce => _staff?.activeEmployees ?? 0;
  int get staffedBranches => _staff?.byStore.where((r) => r.active > 0).length ?? 0;

  /// Stores of this month's comparison (share of sales), biggest first.
  List<StoreSalesModel> get shares =>
      List.of(_month?.stores ?? const <StoreSalesModel>[])..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  /// Recently created / changed stores (newest first).
  List<StoreModel> get recentlyUpdated => (List.of(
    _list,
  )..sort((a, b) => (b.updatedAt ?? DateTime(2000)).compareTo(a.updatedAt ?? DateTime(2000)))).take(5).toList();

  StoreStats statsOf(StoreModel s) {
    final m = _month?.storeById(s.id);
    return (
      today: _today?.storeById(s.id)?.totalAmount ?? 0,
      week: _week?.storeById(s.id)?.totalAmount ?? 0,
      month: m?.totalAmount ?? 0,
      monthChange: m?.changePercent,
      share: (m?.sharePercent ?? 0) / 100,
      rank: m?.rank ?? 0,
      staff: _staff?.activeInStore(s.id) ?? 0,
    );
  }

  /// Highest monthly sales first.
  List<StoreModel> get ranked => List.of(_list)..sort((a, b) => statsOf(b).month.compareTo(statsOf(a).month));

  String? nameOf(String? id) => byId(id ?? '')?.name;

  StoreModel? byId(String id) {
    for (final s in _list) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<StoreModel> visible([String globalQuery = '']) {
    bool matches(StoreModel s, String q) =>
        q.isEmpty || '${s.name} ${s.address ?? ''} ${s.phone ?? ''} ${s.description ?? ''}'.toLowerCase().contains(q);
    final list = _list
        .where(
          (s) => switch (_status) {
            StoreStatusFilter.all => true,
            StoreStatusFilter.active => s.isActive,
            StoreStatusFilter.inactive => !s.isActive,
          },
        )
        .where((s) => matches(s, _query) && matches(s, globalQuery))
        .toList();
    switch (_sort) {
      case StoreSort.revenue:
        list.sort((a, b) => statsOf(b).month.compareTo(statsOf(a).month));
      case StoreSort.today:
        list.sort((a, b) => statsOf(b).today.compareTo(statsOf(a).today));
      case StoreSort.name:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return list;
  }

  void setStatusFilter(StoreStatusFilter v) {
    _status = v;
    notifySafe();
  }

  void setSort(StoreSort v) {
    _sort = v;
    notifySafe();
  }

  void setGridView(bool grid) {
    _gridView = grid;
    notifySafe();
  }

  void setQuery(String v) {
    _query = v.trim().toLowerCase();
    notifySafe();
  }

  Future<void> load() => runTask(() async {
    final now = DateTime.now();
    final (stores, today, week, month, staff) = await (
      _stores.fetchAll(),
      _sales.daily(),
      _sales.weekly(),
      _reports.storeComparison(startDate: DateTime(now.year, now.month), endDate: dateOnly(now)),
      _reports.employees(),
    ).wait;
    _list = stores;
    _today = today;
    _week = week;
    _month = month;
    _staff = staff;
    _loaded = true;
  });

  /// Creates ([isNew]) or updates a store. Returns `null` or the error code.
  Future<String?> save(StoreModel store, {required bool isNew}) async {
    _isSaving = true;
    notifySafe();
    final error = await runAction(() async {
      final saved = isNew ? await _stores.create(store) : await _stores.update(store);
      _list = isNew ? [..._list, saved] : [for (final s in _list) s.id == saved.id ? saved : s];
    });
    _isSaving = false;
    notifySafe();
    return error;
  }

  Future<String?> delete(String id) => runAction(() async {
    await _stores.delete(id);
    _list = _list.where((s) => s.id != id).toList();
  });
}
