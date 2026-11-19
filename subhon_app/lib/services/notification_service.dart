import '../core/network/api_client.dart';
import '../models/notifications_model.dart';

/// `Notifications` (API.md): unpaid and overdue salaries, stores without
/// sales today — calculated on every request.
class NotificationService {
  NotificationService(this._api);

  final ApiClient _api;

  Future<NotificationsModel> list() async => NotificationsModel.fromJson(
    await _api.get('/api/notifications') as Map<String, dynamic>,
  );

  /// Everything shown now counts as read (`unreadCount` becomes 0).
  Future<void> readAll() => _api.post('/api/notifications/read-all');
}
