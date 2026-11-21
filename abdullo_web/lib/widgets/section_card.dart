import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// White card with a title, optional badge, subtitle and trailing actions.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.badge,
    this.trailing,
    this.padding = const EdgeInsets.all(20),
  });

  final String title;
  final String? subtitle;
  final Widget? badge;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          ?badge,
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!, style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4)),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  // Actions hug the right edge instead of taking half the row.
                  Flexible(
                    child: Align(alignment: Alignment.topRight, child: trailing!),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
