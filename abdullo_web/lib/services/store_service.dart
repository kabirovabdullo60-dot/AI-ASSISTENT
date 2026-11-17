import '../core/constants/api_constants.dart';
import '../core/utils/json.dart';
import '../models/store_model.dart';
import 'base_service.dart';

class StoreService extends BaseService {
  StoreService({super.client, super.useMock});

  Future<List<StoreModel>> fetchStores() => mockOr(
    mock: (db) => List.of(db.stores),
    api: () async => asJsonList(await client.get(ApiConstants.stores)).map(StoreModel.fromJson).toList(),
  );
}
