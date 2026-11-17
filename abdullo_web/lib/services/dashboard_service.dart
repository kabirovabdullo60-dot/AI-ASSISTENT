import '../core/constants/api_constants.dart';
import '../core/utils/json.dart';
import '../models/activity_model.dart';
import '../models/overview_model.dart';
import 'base_service.dart';

class DashboardService extends BaseService {
  DashboardService({super.client, super.useMock});

  /// [storeId] `null` = all stores.
  Future<OverviewModel> fetchOverview({String? storeId}) => mockOr(
    mock: (db) => db.overview(storeId: storeId),
    api: () async => OverviewModel.fromJson(
      asJsonMap(await client.get(ApiConstants.overview, query: {'storeId': ?storeId})),
    ),
  );

  Future<List<ActivityModel>> fetchActivity({int limit = 20}) => mockOr(
    mock: (db) => db.activity.take(limit).toList(),
    api: () async => asJsonList(
      await client.get(ApiConstants.activity, query: {'limit': '$limit'}),
    ).map(ActivityModel.fromJson).toList(),
  );
}
