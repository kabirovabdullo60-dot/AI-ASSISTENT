import '../models/page_model.dart';
import '../models/sale_model.dart';
import '../models/store_model.dart';
import '../services/sales_service.dart';
import '../services/store_service.dart';
import 'paged_list_view_model.dart';

/// Sales page by page (newest first), filtered by store and dates, with the
/// total of the filtered sales.
class SalesViewModel extends PagedListViewModel<SaleModel> {
  SalesViewModel(this._sales, this._storesService);

  final SalesService _sales;
  final StoreService _storesService;

  String? _storeId;
  DateTime? _startDate;
  DateTime? _endDate;
  List<StoreModel> _stores = const [];

  String? get storeId => _storeId;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  /// Stores for the filter (loaded with the first page).
  List<StoreModel> get stores => _stores;

  bool get isFiltered =>
      _storeId != null || _startDate != null || _endDate != null;

  Future<void> setFilter({
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _storeId = storeId;
    _startDate = startDate;
    _endDate = endDate;
    return load();
  }

  Future<void> clearFilter() => setFilter();

  @override
  Future<PageModel<SaleModel>> fetch(int page) async {
    if (page == 1 && _stores.isEmpty) {
      _stores = (await _storesService.list(limit: 100)).items;
    }
    return _sales.list(
      storeId: _storeId,
      startDate: _startDate,
      endDate: _endDate,
      page: page,
    );
  }

  Future<void> delete(String id) async {
    await _sales.delete(id);
    removeWhere((s) => s.id == id);
  }
}
