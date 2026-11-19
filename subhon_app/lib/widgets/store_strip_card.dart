import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import 'active_status_badge.dart';
import 'app_icon_box.dart';

/// One store in the horizontal strip on home: name, where it is, whether
/// it works and its sales this month. Tap to open it.
class StoreStripCard extends StatelessWidget {
  const StoreStripCard({
    required this.name,
    required this.active,
    required this.salesLabel,
    required this.salesText,
    required this.onTap,
    this.place,
    super.key,
  });

  final String name;
  final String? place;
  final bool active;
  final String salesLabel;
  final String salesText;
  final VoidCallback onTap;

  static const double width = 240;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return SizedBox(
      width: width,
      child: Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: p.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppIconBox(
                      icon: Icons.storefront_outlined,
                      color: p.primary,
                      background: p.primaryLight,
                      size: 36,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Spacer(),
                    // Shrinks rather than overflows on narrow cards.
                    Flexible(flex: 4, child: ActiveStatusBadge(active: active)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  place ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(salesLabel, style: theme.textTheme.labelSmall),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    salesText,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: p.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
