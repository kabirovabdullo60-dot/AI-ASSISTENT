import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_typography.dart';
import 'app_card.dart';

/// OFAR's period figure: label, amount, and a caption under it (e.g. the
/// change against the previous period).
class FigureCard extends StatelessWidget {
  const FigureCard({
    required this.label,
    required this.value,
    this.valueColor,
    this.caption,
    this.captionColor,
    super.key,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? caption;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              caption!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: captionColor ?? context.palette.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
