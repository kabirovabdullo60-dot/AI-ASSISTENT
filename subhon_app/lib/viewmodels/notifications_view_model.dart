import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

/// The bell: notifications and how many are unread. Opening the list
/// marks them all as read.
class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel(this._service);

  final NotificationService _service;

  List<NotificationModel> _items = const [];
  int _unread = 0;
  bool _isLoading = false;
  bool _loaded = false;
  Object? _error;

  List<NotificationModel> get items => _items;
  int get unreadCount => _unread;
  bool get isLoading => _isLoading;
  bool get hasData => _loaded;
  Object? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _service.list();
      _items = result.items;
      _unread = result.unreadCount;
      _loaded = true;
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// The list was opened: the badge goes away (`read-all`); the items keep
  /// their "new" mark until the next load.
  Future<void> markAllRead() async {
    if (_unread == 0) return;
    try {
      await _service.readAll();
      _unread = 0;
      notifyListeners();
    } on ApiException {
      // The badge simply stays; nothing else depends on it.
    }
  }
}
