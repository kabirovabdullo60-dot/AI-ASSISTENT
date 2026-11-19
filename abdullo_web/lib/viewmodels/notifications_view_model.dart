import '../core/network/api_client.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import 'base_view_model.dart';

/// The bell in the top bar (GET /api/notifications, POST /api/notifications/read-all).
class NotificationsViewModel extends BaseViewModel {
  NotificationsViewModel(this._service);

  final NotificationService _service;

  List<NotificationModel> _items = const [];
  int _unread = 0;

  List<NotificationModel> get items => _items;
  int get unreadCount => _unread;

  Future<void> load() => runTask(() async {
    final r = await _service.list();
    _items = r.items;
    _unread = r.unreadCount;
  });

  /// Called when the menu opens: the badge goes to 0.
  Future<void> markAllRead() async {
    if (_unread == 0) return;
    _unread = 0;
    notifySafe();
    try {
      await _service.readAll();
    } on ApiException {
      // Not critical — the badge comes back on the next load.
    }
  }
}
