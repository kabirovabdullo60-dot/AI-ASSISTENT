import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import 'app_card.dart';

/// A sales target: the label, sales so far against the goal with a
/// progress bar, or [emptyText] (tap to set one) when there is no goal.
class TargetProgressCard extends StatelessWidget {
  const TargetProgressCard({
    required this.label,
    required this.sales,
    required this.salesText,
    required this.target,
    required this.targetText,
    required this.percentText,
    required this.emptyText,
    required this.onTap,
    super.key,
  });

  final String label;
  final double sales;
  final String salesText;

  /// `null`: no target yet.
  final double? target;
  final String? targetText;
  final String? percentText;
  final String emptyText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final goal = target;
    final share = goal == null || goal <= 0 ? 0.0 : (sales / goal);
    final reached = share >= 1;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(label, style: theme.textTheme.bodySmall),
                  ),
                  Icon(Icons.edit_outlined, size: 16, color: p.textSecondary),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (goal == null)
                Text(
                  emptyText,
                  style: theme.textTheme.bodyMedium?.copyWith(color: p.primary),
                )
              else ...[
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$salesText / $targetText',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(99)),
                  child: LinearProgressIndicator(
                    value: share.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: p.surfaceMuted,
                    color: reached ? p.success : p.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  percentText!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: reached ? p.success : p.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
