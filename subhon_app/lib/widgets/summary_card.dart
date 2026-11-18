import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_typography.dart';

/// OFAR's single gradient card (the "total balance" card): a headline
/// figure and two smaller ones under it.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    required this.title,
    required this.value,
    required this.parts,
    super.key,
  });

  final String title;
  final String value;

  /// Two `(label, value)` pairs shown under the headline.
  final List<(String, String)> parts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final onCard = theme.textTheme.bodySmall?.copyWith(
      color: p.onPrimary.withValues(alpha: 0.85),
    );
    Widget part(String label, String text) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: onCard),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: theme.textTheme.titleSmall?.copyWith(
                color: p.onPrimary,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: '$title: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          gradient: LinearGradient(
            colors: [p.primary, p.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: p.primary.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: onCard),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: p.onPrimary,
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                for (final (i, (label, text)) in parts.indexed) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.lg),
                  part(label, text),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
