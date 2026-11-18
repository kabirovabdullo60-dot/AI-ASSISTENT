import '../core/utils/json.dart';

enum ActivityType { sale, payroll, store, employee, profile }

/// `CREATED`, `UPDATED`, `DELETED`, `STATUS_CHANGED`, `PAID`, `CANCELLED` (GET /api/activity).
enum ActivityAction { created, updated, deleted, statusChanged, paid, cancelled }

/// A row of "Recent Business Activity" — `ActivityOut` from GET /api/activity
/// (or, while that log is still empty, built from the latest sales and salary payments).
class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.time,
    this.amount,
    this.action,
    this.detail = '',
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    final period = json['period'] as String?;
    final changed = (json['changedFields'] as List?)?.map((e) => '$e').join(', ');
    return ActivityModel(
      id: asString(json['id']),
      type: _type(json['type']),
      action: _action(json['action']),
      title: asString(json['entityName']),
      amount: asDoubleOrNull(json['amount']),
      time: asDate(json['createdAt']),
      detail: [
        if ((json['note'] as String?)?.isNotEmpty ?? false) json['note'] as String,
        if (changed != null && changed.isNotEmpty) changed,
        ?status,
        ?period,
      ].join(' · '),
    );
  }

  static ActivityType _type(Object? v) => switch ('$v') {
    'SALE' => ActivityType.sale,
    'PAYROLL' => ActivityType.payroll,
    'EMPLOYEE' => ActivityType.employee,
    'PROFILE' => ActivityType.profile,
    _ => ActivityType.store,
  };

  static ActivityAction? _action(Object? v) => switch ('$v') {
    'CREATED' => ActivityAction.created,
    'UPDATED' => ActivityAction.updated,
    'DELETED' => ActivityAction.deleted,
    'STATUS_CHANGED' => ActivityAction.statusChanged,
    'PAID' => ActivityAction.paid,
    'CANCELLED' => ActivityAction.cancelled,
    _ => null,
  };

  final String id;
  final ActivityType type;

  /// Store name (store, sale), employee name (employee, payment) or user name (profile).
  final String title;

  /// Signed TJS: + income, - salary paid. Null when the change has no amount.
  final double? amount;
  final DateTime time;

  /// What happened; null for rows built from sales / payments.
  final ActivityAction? action;

  /// Note, changed fields, new status or salary month.
  final String detail;

  String get searchText => '$title $detail'.toLowerCase();
}
