import '../models/activity_action.dart';
import '../models/activity_model.dart';
import '../models/activity_type.dart';
import 'generated/app_localizations.dart';

/// The translated sentence for one change, built from its type + action
/// (the API sends codes, not sentences).
String activityText(AppLocalizations l10n, ActivityModel a) {
  final name = a.entityName;
  String status() => switch (a.status) {
    'ACTIVE' => l10n.statusActive,
    'INACTIVE' => l10n.statusInactive,
    _ => a.status ?? '',
  };
  return switch ((a.type, a.action)) {
    (ActivityType.store, ActivityAction.created) => l10n.activityStoreCreated(
      name,
    ),
    (ActivityType.store, ActivityAction.updated) => l10n.activityStoreUpdated(
      name,
    ),
    (ActivityType.store, ActivityAction.deleted) => l10n.activityStoreDeleted(
      name,
    ),
    (ActivityType.store, ActivityAction.statusChanged) =>
      l10n.activityStoreStatus(name, status()),
    (ActivityType.sale, ActivityAction.created) => l10n.activitySaleCreated(
      name,
    ),
    (ActivityType.sale, ActivityAction.updated) => l10n.activitySaleUpdated(
      name,
    ),
    (ActivityType.sale, ActivityAction.deleted) => l10n.activitySaleDeleted(
      name,
    ),
    (ActivityType.employee, ActivityAction.created) =>
      l10n.activityEmployeeCreated(name),
    (ActivityType.employee, ActivityAction.updated) =>
      l10n.activityEmployeeUpdated(name),
    (ActivityType.employee, ActivityAction.deleted) =>
      l10n.activityEmployeeDeleted(name),
    (ActivityType.employee, ActivityAction.statusChanged) =>
      l10n.activityEmployeeStatus(name, status()),
    (ActivityType.payroll, ActivityAction.paid) => l10n.activityPayrollPaid(
      name,
    ),
    (ActivityType.payroll, ActivityAction.cancelled) =>
      l10n.activityPayrollCancelled(name),
    (ActivityType.profile, _) => l10n.activityProfileUpdated,
    _ => l10n.activityOther(name),
  };
}
