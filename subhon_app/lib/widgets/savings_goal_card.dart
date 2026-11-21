import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

/// A savings goal: its name, a progress bar, "1 500 из 50 000" and what is
/// left, with "Пополнить".
class SavingsGoalCard extends StatelessWidget {
  const SavingsGoalCard({
    required this.name,
    required this.progress,
    required this.savedText,
    required this.subtitle,
    required this.topUpLabel,
    required this.onTap,
    required this.onTopUp,
    super.key,
  });

  final String name;

  /// 0…1.
  final double progress;
  final String savedText;
  final String subtitle;
  final String topUpLabel;
  final VoidCallback onTap;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final theme = Theme.of(context);
    final done = progress >= 1;
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: BorderSide(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    done ? Icons.emoji_events_rounded : Icons.savings_outlined,
                    color: done ? p.success : p.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(name, style: theme.textTheme.titleSmall),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: done ? p.success : p.primary,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: onTopUp,
                    child: Text(topUpLabel),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: p.primaryLight,
                    color: done ? p.success : p.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(savedText, style: theme.textTheme.bodyMedium),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
