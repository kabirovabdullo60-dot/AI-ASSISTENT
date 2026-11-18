import '../models/page_model.dart';
import '../models/store_model.dart';
import '../services/store_service.dart';
import 'paged_list_view_model.dart';

/// Stores of the business, page by page, with search.
class StoresViewModel extends PagedListViewModel<StoreModel> {
  StoresViewModel(this._stores);

  final StoreService _stores;
  String _search = '';

  String get search => _search;

  Future<void> setSearch(String value) {
    _search = value.trim();
    return load();
  }

  @override
  Future<PageModel<StoreModel>> fetch(int page) =>
      _stores.list(search: _search.isEmpty ? null : _search, page: page);

  /// Soft delete; refused with `STORE_HAS_ACTIVE_EMPLOYEES` (thrown).
  Future<void> delete(String id) async {
    await _stores.delete(id);
    removeWhere((s) => s.id == id);
  }
}
