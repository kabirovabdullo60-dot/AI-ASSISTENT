import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/activity_model.dart';
import '../models/page_model.dart';

class ActivityService {
  ActivityService(this._api);

  final ApiClient _api;

  /// GET /api/activity — newest first.
  Future<PageModel<ActivityModel>> list({String? storeId, int page = 1, int limit = 20}) async => PageModel.fromJson(
    await _api.get(ApiConstants.activity, query: {'storeId': storeId, 'page': page, 'limit': limit}),
    ActivityModel.fromJson,
  );
}
