import '../core/utils/money.dart';
import 'activity_action.dart';
import 'activity_type.dart';

/// `ActivityOut` from the API contract (API.md / Swagger): one change in
/// the business. The sentence is built in the app from [type] + [action].
class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.type,
    required this.action,
    required this.entityId,
    required this.entityName,
    required this.storeId,
    required this.storeName,
    required this.employeeId,
    required this.amount,
    required this.note,
    required this.changedFields,
    required this.status,
    required this.period,
    required this.actorName,
    required this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id: json['id'] as String,
    type: ActivityType.fromJson(json['type'] as String),
    action: ActivityAction.fromJson(json['action'] as String),
    entityId: json['entityId'] as String,
    entityName: json['entityName'] as String,
    storeId: json['storeId'] as String?,
    storeName: json['storeName'] as String?,
    employeeId: json['employeeId'] as String?,
    amount: json['amount'] == null
        ? null
        : parseMoney(json['amount'] as String),
    note: json['note'] as String?,
    changedFields: (json['changedFields'] as List<dynamic>?)?.cast<String>(),
    status: json['status'] as String?,
    period: json['period'] as String?,
    actorName: json['actorName'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
  );

  final String id;
  final ActivityType type;
  final ActivityAction action;
  final String entityId;

  /// Name at the time of the change (store, employee or user).
  final String entityName;
  final String? storeId;
  final String? storeName;
  final String? employeeId;

  /// Signed by money direction: sales positive, salary payments negative.
  final double? amount;
  final String? note;
  final List<String>? changedFields;

  /// For STATUS_CHANGED: `ACTIVE` / `INACTIVE`.
  final String? status;

  /// For PAYROLL: the salary month, `YYYY-MM`.
  final String? period;
  final String actorName;
  final DateTime createdAt;
}
