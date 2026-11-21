import '../models/notification_kind.dart';
import '../models/notification_model.dart';
import 'generated/app_localizations.dart';

/// The translated title and text of a notification. [money] formats the
/// amount.
(String, String) notificationText(
  AppLocalizations l10n,
  NotificationModel n,
  String Function(double amount) money,
) {
  final amount = money(n.amount ?? 0);
  return switch (n.kind) {
    NotificationKind.salaryOverdue => (
      l10n.notifSalaryOverdueTitle,
      l10n.notifSalaryOverdueBody(n.count, amount),
    ),
    NotificationKind.unpaidSalaries => (
      l10n.notifUnpaidTitle,
      l10n.notifUnpaidBody(n.count, amount),
    ),
    NotificationKind.storeNoSalesToday => (
      l10n.notifNoSalesTitle,
      l10n.notifNoSalesBody(n.storeName ?? ''),
    ),
    NotificationKind.unknown => (l10n.notifOther, ''),
  };
}
