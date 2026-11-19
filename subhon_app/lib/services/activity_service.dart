import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/local_date.dart';
import '../models/activity_model.dart';
import '../models/page_model.dart';

/// `Activity` (API.md): the log of every change in the business, newest
/// first.
class ActivityService {
  ActivityService(this._api);

  final ApiClient _api;

  /// [storeId]: a store's operations log; [employeeId]: one employee.
  Future<PageModel<ActivityModel>> list({
    String? storeId,
    String? employeeId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = ApiConstants.pageSize,
  }) async => PageModel.fromJson(
    await _api.get(
          '/api/activity',
          query: {
            'storeId': storeId,
            'employeeId': employeeId,
            'startDate': startDate == null ? null : formatLocalDate(startDate),
            'endDate': endDate == null ? null : formatLocalDate(endDate),
            'page': page,
            'limit': limit,
          },
        )
        as Map<String, dynamic>,
    ActivityModel.fromJson,
  );
}
