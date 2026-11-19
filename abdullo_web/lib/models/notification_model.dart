import '../core/utils/json.dart';

enum NotificationKind { unpaidSalaries, salaryOverdue, storeNoSalesToday }

/// The page to open: `STORES`, `SALES`, `PAYROLL`.
enum NotificationLink { stores, sales, payroll }

/// `NotificationOut` from GET /api/notifications (calculated by the server from your data).
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.kind,
    required this.warning,
    required this.count,
    required this.link,
    required this.read,
    required this.createdAt,
    this.amount,
    this.storeName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: asString(json['id']),
    kind: switch ('${json['kind']}') {
      'SALARY_OVERDUE' => NotificationKind.salaryOverdue,
      'STORE_NO_SALES_TODAY' => NotificationKind.storeNoSalesToday,
      _ => NotificationKind.unpaidSalaries,
    },
    warning: json['severity'] == 'WARNING',
    count: asInt(json['count']),
    amount: asDoubleOrNull(json['amount']),
    storeName: json['storeName'] as String?,
    link: switch ('${json['link']}') {
      'STORES' => NotificationLink.stores,
      'SALES' => NotificationLink.sales,
      _ => NotificationLink.payroll,
    },
    read: asBool(json['read']),
    createdAt: asDate(json['createdAt']),
  );

  final String id;
  final NotificationKind kind;

  /// Severity `WARNING` (otherwise `INFO`).
  final bool warning;

  /// Employees (unpaid), employee-months (overdue) or 1 (store).
  final int count;

  /// Salary still to pay, TJS. Null for stores.
  final double? amount;
  final String? storeName;
  final NotificationLink link;
  final bool read;
  final DateTime createdAt;
}
