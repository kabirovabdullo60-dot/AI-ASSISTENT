import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_typography.dart';

/// OFAR's share row (expense structure): name, amount, a bar and a share.
class ShareBarRow extends StatelessWidget {
  const ShareBarRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.share,
    required this.shareText,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  /// 0…1.
  final double share;
  final String shareText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: p.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: share.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: p.surfaceMuted,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 52,
                child: Text(
                  shareText,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
