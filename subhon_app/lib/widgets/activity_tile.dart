import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/activity_text.dart';
import '../l10n/l10n.dart';
import '../models/activity_action.dart';
import '../models/activity_model.dart';
import '../models/activity_type.dart';
import 'record_tile.dart';

/// One change of the activity log: what happened, who and when, and the
/// amount (sales +, salary payments −; grey when deleted or cancelled).
class ActivityTile extends StatelessWidget {
  const ActivityTile({required this.activity, super.key});

  final ActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final a = activity;
    final undone =
        a.action == ActivityAction.deleted ||
        a.action == ActivityAction.cancelled;
    final (icon, color, background) = switch (a.type) {
      ActivityType.sale => (
        Icons.point_of_sale_rounded,
        p.success,
        p.successLight,
      ),
      ActivityType.payroll => (
        Icons.payments_outlined,
        p.primary,
        p.primaryLight,
      ),
      ActivityType.store => (
        Icons.storefront_outlined,
        p.warning,
        p.warningLight,
      ),
      ActivityType.employee => (
        Icons.badge_outlined,
        p.primary,
        p.primaryLight,
      ),
      _ => (Icons.manage_accounts_outlined, p.textSecondary, p.surfaceMuted),
    };
    final amount = a.amount;
    return RecordTile(
      icon: undone ? Icons.remove_circle_outline_rounded : icon,
      iconColor: undone ? p.error : color,
      iconBackground: undone ? p.errorLight : background,
      title: activityText(l10n, a),
      subtitle: l10n.activityBy(
        a.actorName,
        context.formatDateTime(a.createdAt),
      ),
      value: amount == null ? null : context.money(amount, signed: true),
      valueColor: amount == null || undone
          ? p.textSecondary
          : (amount >= 0 ? p.success : p.error),
    );
  }
}
