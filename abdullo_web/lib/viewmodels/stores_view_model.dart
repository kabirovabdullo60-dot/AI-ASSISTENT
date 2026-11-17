import '../models/activity_model.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';
import 'base_view_model.dart';

enum StoreStatusFilter { all, active, inactive }

enum StoreSort {
  revenue('Highest Revenue'),
  today("Today's Sales"),
  name('Name A–Z');

  const StoreSort(this.label);
  final String label;
}

/// One row of "Regional Sales Distribution".
typedef RegionShare = ({String region, int stores, int inactive, double sales, double share});

class StoresViewModel extends BaseViewModel {
  StoresViewModel(this._service);

  final StoreService _service;
  List<StoreModel> _stores = const [];
  List<ActivityModel> _log = const [];
  bool _loaded = false;
  bool _isSaving = false;
  StoreStatusFilter _status = StoreStatusFilter.all;
  StoreSort _sort = StoreSort.revenue;
  bool _gridView = true;
  String _query = '';

  List<StoreModel> get stores => _stores;
  List<ActivityModel> get operationsLog => _log;
  bool get hasData => _loaded;
  bool get isSaving => _isSaving;
  StoreStatusFilter get statusFilter => _status;
  StoreSort get sort => _sort;
  bool get gridView => _gridView;

  Iterable<StoreModel> get _active => _stores.where((s) => s.isActive);
  int get activeCount => _active.length;
  int get inactiveCount => _stores.length - activeCount;
  double get operatingRatio => _stores.isEmpty ? 0 : activeCount / _stores.length;
  double get totalSales => _stores.fold(0, (sum, s) => sum + s.monthlySales);
  double get todayTotal => _stores.fold(0, (sum, s) => sum + s.todaySales);
  int get workforce => _stores.fold(0, (sum, s) => sum + s.staffCount);
  int get staffedBranches => _stores.where((s) => s.staffCount > 0).length;

  /// Highest monthly sales first.
  List<StoreModel> get ranked => List.of(_stores)..sort((a, b) => b.monthlySales.compareTo(a.monthlySales));

  List<StoreModel> top(int n) => ranked.take(n).toList();

  /// Share of all monthly sales, 0..1.
  double shareOf(StoreModel store) => totalSales == 0 ? 0 : store.monthlySales / totalSales;

  /// 1-based rank by monthly sales.
  int rankOf(StoreModel store) => ranked.indexWhere((s) => s.id == store.id) + 1;

  String? nameOf(String? id) {
    for (final s in _stores) {
      if (s.id == id) return s.name;
    }
    return null;
  }

  StoreModel? byId(String id) {
    for (final s in _stores) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Stores after status filter, page search, top-bar search and sort.
  List<StoreModel> visible([String globalQuery = '']) {
    bool matches(StoreModel s, String q) =>
        q.isEmpty || '${s.name} ${s.city} ${s.address} ${s.phone} ${s.type}'.toLowerCase().contains(q);
    final list = _stores
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
        list.sort((a, b) => b.monthlySales.compareTo(a.monthlySales));
      case StoreSort.today:
        list.sort((a, b) => b.todaySales.compareTo(a.todaySales));
      case StoreSort.name:
        list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  }

  List<StoreModel> filtered(String query) => visible(query);

  List<RegionShare> get regions {
    final map = <String, List<StoreModel>>{};
    for (final s in _stores) {
      map.putIfAbsent(s.region.isEmpty ? 'Other' : s.region, () => []).add(s);
    }
    final rows = [
      for (final e in map.entries)
        (
          region: e.key,
          stores: e.value.length,
          inactive: e.value.where((s) => !s.isActive).length,
          sales: e.value.fold<double>(0, (sum, s) => sum + s.monthlySales),
          share: totalSales == 0 ? 0.0 : e.value.fold<double>(0, (sum, s) => sum + s.monthlySales) / totalSales,
        ),
    ];
    rows.sort((a, b) => b.sales.compareTo(a.sales));
    return rows;
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
    final (stores, log) = await (_service.fetchStores(), _service.fetchOperationsLog()).wait;
    _stores = stores;
    _log = log;
    _loaded = true;
  }, errorMessage: 'Could not load stores.');

  /// Creates a store when [isNew], otherwise updates it. Returns `true` on success.
  Future<bool> save(StoreModel store, {required bool isNew}) async {
    if (_isSaving) return false;
    _isSaving = true;
    notifySafe();
    try {
      final saved = isNew ? await _service.createStore(store) : await _service.updateStore(store);
      _stores = isNew ? [..._stores, saved] : [for (final s in _stores) s.id == saved.id ? saved : s];
      _log = await _service.fetchOperationsLog();
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSaving = false;
      notifySafe();
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _service.deleteStore(id);
      _stores = _stores.where((s) => s.id != id).toList();
      _log = await _service.fetchOperationsLog();
      notifySafe();
      return true;
    } catch (_) {
      return false;
    }
  }
}
