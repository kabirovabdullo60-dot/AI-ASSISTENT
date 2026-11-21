import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../models/assistant_action_status.dart';
import 'assistant_action_labels.dart';

/// A change the assistant proposed, under its message: the summary as the
/// server wrote it, and Cancel / Confirm (red for a delete). Done shows ✓;
/// failed shows why and "Confirm again"; cancelled or expired is greyed out.
/// Both buttons are disabled while a request runs ([busy]).
class AssistantActionCard extends StatelessWidget {
  const AssistantActionCard({
    required this.summary,
    required this.status,
    required this.danger,
    required this.busy,
    required this.labels,
    required this.onConfirm,
    required this.onCancel,
    this.problem,
    super.key,
  });

  final String summary;
  final AssistantActionStatus status;
  final bool danger;
  final bool busy;

  /// Why it failed or could not be sent (already translated).
  final String? problem;
  final AssistantActionLabels labels;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    final closed = status.isClosed;
    final done = status == AssistantActionStatus.done;
    final failed = status == AssistantActionStatus.failed;
    final open = status == AssistantActionStatus.proposed || failed;
    final (icon, iconColor) = switch (status) {
      AssistantActionStatus.done => (Icons.check_circle_rounded, p.success),
      AssistantActionStatus.failed => (Icons.error_outline_rounded, p.error),
      AssistantActionStatus.cancelled ||
      AssistantActionStatus.expired => (Icons.block_rounded, p.textSecondary),
      AssistantActionStatus.proposed => (
        danger ? Icons.delete_outline_rounded : Icons.bolt_rounded,
        danger ? p.error : p.primary,
      ),
    };
    final card = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm, right: 32),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: danger && open ? p.error.withValues(alpha: 0.5) : p.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(summary, style: theme.textTheme.bodyMedium)),
            ],
          ),
          if (problem != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              problem!,
              style: theme.textTheme.bodySmall?.copyWith(color: p.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          if (done)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                labels.done,
                style: theme.textTheme.labelLarge?.copyWith(color: p.success),
              ),
            )
          else if (closed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                status == AssistantActionStatus.expired
                    ? labels.expired
                    : labels.cancelled,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.textSecondary,
                ),
              ),
            )
          else
            // Wraps on narrow phones and long words (ru / tg) instead of
            // running off the card.
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                if (busy)
                  const Padding(
                    padding: EdgeInsets.only(right: AppSpacing.sm),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                TextButton(
                  onPressed: busy ? null : onCancel,
                  child: Text(labels.cancel),
                ),
                FilledButton(
                  style: danger
                      ? FilledButton.styleFrom(
                          backgroundColor: p.error,
                          foregroundColor: p.onPrimary,
                        )
                      : null,
                  onPressed: busy ? null : onConfirm,
                  child: Text(failed ? labels.confirmAgain : labels.confirm),
                ),
              ],
            ),
        ],
      ),
    );
    return closed ? Opacity(opacity: 0.6, child: card) : card;
  }
}
