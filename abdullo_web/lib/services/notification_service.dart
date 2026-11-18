import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/notification_model.dart';

class NotificationService {
  NotificationService(this._api);

  final ApiClient _api;

  /// GET /api/notifications — WARNING first, then newest.
  Future<({List<NotificationModel> items, int unreadCount})> list() async {
    final json = asJsonMap(await _api.get(ApiConstants.notifications));
    return (
      items: asJsonList(json['items']).map(NotificationModel.fromJson).toList(),
      unreadCount: asInt(json['unreadCount']),
    );
  }

  /// POST /api/notifications/read-all → 204.
  Future<void> readAll() => _api.post(ApiConstants.notificationsReadAll);
}
