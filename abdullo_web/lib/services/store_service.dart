import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/page_model.dart';
import '../models/store_model.dart';

class StoreService {
  StoreService(this._api);

  final ApiClient _api;

  /// All stores (walks through every page, 100 per page).
  Future<List<StoreModel>> fetchAll() async {
    final all = <StoreModel>[];
    for (var page = 1; ; page++) {
      final p = PageModel.fromJson(
        await _api.get(ApiConstants.stores, query: {'page': page, 'limit': 100, 'sort': 'name'}),
        StoreModel.fromJson,
      );
      all.addAll(p.items);
      if (page >= p.pages || p.items.isEmpty) return all;
    }
  }

  Future<StoreModel> create(StoreModel store) async =>
      StoreModel.fromJson(asJsonMap(await _api.post(ApiConstants.stores, store.toJson())));

  Future<StoreModel> update(StoreModel store) async =>
      StoreModel.fromJson(asJsonMap(await _api.put(ApiConstants.store(store.id), store.toJson())));

  /// Soft delete — sales history stays.
  Future<void> delete(String id) => _api.delete(ApiConstants.store(id));
}
