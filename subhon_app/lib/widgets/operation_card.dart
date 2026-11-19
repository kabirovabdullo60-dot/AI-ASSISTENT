import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/operation_text.dart';
import '../models/activity_action.dart';
import '../models/activity_model.dart';
import '../models/activity_type.dart';

/// One operation of the history, as a rounded card: an icon with a small
/// status mark, the store (or employee) and what happened, and the amount
/// on the right (incoming green with "+", outgoing in the text colour).
class OperationCard extends StatelessWidget {
  const OperationCard({required this.operation, super.key});

  final ActivityModel operation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = context.palette;
    final a = operation;
    final (title, what) = operationText(l10n, a);
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: background,
                child: Icon(icon, color: color),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: p.surface,
                  child: Icon(
                    undone ? Icons.cancel_rounded : Icons.check_circle_rounded,
                    size: 17,
                    color: undone ? p.error : p.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  what,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (amount != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              context.money(amount, signed: true),
              style: theme.textTheme.titleSmall?.copyWith(
                color: undone
                    ? p.textSecondary
                    : amount > 0
                    ? p.success
                    : p.textPrimary,
                decoration: undone ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
