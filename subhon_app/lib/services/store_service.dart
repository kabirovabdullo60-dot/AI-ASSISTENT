import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/page_model.dart';
import '../models/store_create_model.dart';
import '../models/store_model.dart';
import '../models/store_status.dart';
import '../models/store_update_model.dart';

/// `Stores` (API.md).
class StoreService {
  StoreService(this._api);

  final ApiClient _api;

  Future<PageModel<StoreModel>> list({
    String? search,
    StoreStatus? status,
    int page = 1,
    int limit = ApiConstants.pageSize,
    String? sort,
  }) async => PageModel.fromJson(
    await _api.get(
          '/api/stores',
          query: {
            'search': search,
            'status': status?.json,
            'page': page,
            'limit': limit,
            'sort': sort,
          },
        )
        as Map<String, dynamic>,
    StoreModel.fromJson,
  );

  Future<StoreModel> get(String id) async => StoreModel.fromJson(
    await _api.get('/api/stores/$id') as Map<String, dynamic>,
  );

  Future<StoreModel> create(StoreCreateModel store) async =>
      StoreModel.fromJson(
        await _api.post('/api/stores', body: store.toJson())
            as Map<String, dynamic>,
      );

  Future<StoreModel> update(
    String id,
    StoreUpdateModel update, {
    Set<String> clear = const {},
  }) async => StoreModel.fromJson(
    await _api.put('/api/stores/$id', body: update.toJson(clear: clear))
        as Map<String, dynamic>,
  );

  /// Soft delete; refused with `STORE_HAS_ACTIVE_EMPLOYEES`.
  Future<void> delete(String id) => _api.delete('/api/stores/$id');
}
