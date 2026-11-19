import '../core/utils/money.dart';
import 'notification_kind.dart';
import 'notification_link.dart';

/// `NotificationOut` from the API contract (API.md / Swagger).
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.kind,
    required this.isWarning,
    required this.count,
    required this.amount,
    required this.storeId,
    required this.storeName,
    required this.link,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        kind: NotificationKind.fromJson(json['kind'] as String),
        isWarning: json['severity'] == 'WARNING',
        count: json['count'] as int,
        amount: json['amount'] == null
            ? null
            : parseMoney(json['amount'] as String),
        storeId: json['storeId'] as String?,
        storeName: json['storeName'] as String?,
        link: NotificationLink.fromJson(json['link'] as String),
        read: json['read'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );

  final String id;
  final NotificationKind kind;

  /// `severity: WARNING` (otherwise INFO).
  final bool isWarning;
  final int count;

  /// Salary still to pay; `null` for stores.
  final double? amount;
  final String? storeId;
  final String? storeName;
  final NotificationLink link;
  final bool read;
  final DateTime createdAt;
}
