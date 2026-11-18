import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import '../core/theme/app_typography.dart';
import 'app_icon_box.dart';

/// A row of a list in OFAR's operation-row layout: icon, title, subtitle,
/// amount (or value) and an optional badge under it.
class RecordTile extends StatelessWidget {
  const RecordTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.subtitle,
    this.value,
    this.valueColor,
    this.badge,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? subtitle;
  final String? value;
  final Color? valueColor;
  final Widget? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          child: Row(
            children: [
              AppIconBox(
                icon: icon,
                color: iconColor,
                background: iconBackground,
                size: 42,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null || badge != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (value != null)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            value!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: valueColor,
                              fontFeatures: AppTypography.tabularFigures,
                            ),
                          ),
                        ),
                      if (badge != null) ...[const SizedBox(height: 4), badge!],
                    ],
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
