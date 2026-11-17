import '../models/store_model.dart';
import '../services/store_service.dart';
import 'base_view_model.dart';

class StoresViewModel extends BaseViewModel {
  StoresViewModel(this._service);

  final StoreService _service;
  List<StoreModel> _stores = const [];
  bool _loaded = false;

  List<StoreModel> get stores => _stores;
  bool get hasData => _loaded;
  int get activeCount => _stores.where((s) => s.isActive).length;
  double get totalSales => _stores.fold(0, (sum, s) => sum + s.monthlySales);

  /// Highest sales first.
  List<StoreModel> get ranked => List.of(_stores)..sort((a, b) => b.monthlySales.compareTo(a.monthlySales));

  List<StoreModel> top(int n) => ranked.take(n).toList();

  /// Share of all sales, 0..1.
  double shareOf(StoreModel store) => totalSales == 0 ? 0 : store.monthlySales / totalSales;

  String? nameOf(String? id) {
    for (final s in _stores) {
      if (s.id == id) return s.name;
    }
    return null;
  }

  List<StoreModel> filtered(String query) => query.isEmpty
      ? ranked
      : ranked
            .where((s) => '${s.name} ${s.type} ${s.area} ${s.manager}'.toLowerCase().contains(query))
            .toList();

  Future<void> load() => runTask(() async {
    _stores = await _service.fetchStores();
    _loaded = true;
  }, errorMessage: 'Could not load stores.');
}
