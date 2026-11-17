import '../core/constants/api_constants.dart';
import '../core/utils/json.dart';
import '../models/activity_model.dart';
import '../models/store_analytics_model.dart';
import '../models/store_model.dart';
import 'base_service.dart';

class StoreService extends BaseService {
  StoreService({super.client, super.useMock});

  Future<List<StoreModel>> fetchStores() => mockOr(
    mock: (db) => List.of(db.stores),
    api: () async => asJsonList(await client.get(ApiConstants.stores)).map(StoreModel.fromJson).toList(),
  );

  Future<StoreModel> createStore(StoreModel draft) => mockOr(
    mock: (db) => db.addStore(draft),
    api: () async => StoreModel.fromJson(asJsonMap(await client.post(ApiConstants.stores, draft.toJson()))),
  );

  Future<StoreModel> updateStore(StoreModel store) => mockOr(
    mock: (db) => db.updateStore(store),
    api: () async => StoreModel.fromJson(asJsonMap(await client.put(ApiConstants.store(store.id), store.toJson()))),
  );

  Future<void> deleteStore(String id) => mockOr(
    mock: (db) => db.deleteStore(id),
    api: () async {
      await client.delete(ApiConstants.store(id));
    },
  );

  Future<StoreAnalyticsModel> fetchAnalytics(String id) => mockOr(
    mock: (db) => db.analytics(id),
    api: () async => StoreAnalyticsModel.fromJson(asJsonMap(await client.get(ApiConstants.storeAnalytics(id)))),
  );

  Future<List<ActivityModel>> fetchOperationsLog() => mockOr(
    mock: (db) => db.storeLog.take(5).toList(),
    api: () async => asJsonList(await client.get(ApiConstants.storesLog)).map(ActivityModel.fromJson).toList(),
  );
}
