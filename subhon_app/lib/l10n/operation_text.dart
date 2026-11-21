import '../models/activity_action.dart';
import '../models/activity_model.dart';
import '../models/activity_type.dart';
import 'generated/app_localizations.dart';

/// One operation of the history as two lines: who or where (the store, or
/// the employee for staff and salary) and what happened, in short.
(String, String) operationText(AppLocalizations l10n, ActivityModel a) {
  String status() => switch (a.status) {
    'ACTIVE' => l10n.statusActive,
    'INACTIVE' => l10n.statusInactive,
    _ => a.status ?? '',
  };
  final title = switch (a.type) {
    ActivityType.sale || ActivityType.store => a.storeName ?? a.entityName,
    _ => a.entityName,
  };
  final what = switch ((a.type, a.action)) {
    (ActivityType.sale, ActivityAction.created) => l10n.opSale,
    (ActivityType.sale, ActivityAction.updated) => l10n.opSaleEdited,
    (ActivityType.sale, ActivityAction.deleted) => l10n.opSaleDeleted,
    (ActivityType.payroll, ActivityAction.paid) => l10n.opSalary,
    (ActivityType.payroll, ActivityAction.cancelled) => l10n.opSalaryCancelled,
    (ActivityType.store, ActivityAction.created) => l10n.opStoreNew,
    (ActivityType.store, ActivityAction.updated) => l10n.opStoreEdited,
    (ActivityType.store, ActivityAction.deleted) => l10n.opStoreDeleted,
    (ActivityType.employee, ActivityAction.created) => l10n.opEmployeeNew,
    (ActivityType.employee, ActivityAction.updated) => l10n.opEmployeeEdited,
    (ActivityType.employee, ActivityAction.deleted) => l10n.opEmployeeDeleted,
    (_, ActivityAction.statusChanged) => l10n.opStatus(status()),
    (ActivityType.profile, _) => l10n.opProfile,
    _ => l10n.opOther,
  };
  return (title, what);
}
