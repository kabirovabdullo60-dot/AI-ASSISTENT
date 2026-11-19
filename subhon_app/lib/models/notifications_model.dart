import 'notification_model.dart';

/// `NotificationsOut` from the API contract (API.md / Swagger).
class NotificationsModel {
  const NotificationsModel({required this.items, required this.unreadCount});

  factory NotificationsModel.fromJson(Map<String, dynamic> json) =>
      NotificationsModel(
        items: [
          for (final e in json['items'] as List<dynamic>)
            NotificationModel.fromJson(e as Map<String, dynamic>),
        ],
        unreadCount: json['unreadCount'] as int,
      );

  /// WARNING first, then newest first.
  final List<NotificationModel> items;
  final int unreadCount;
}
