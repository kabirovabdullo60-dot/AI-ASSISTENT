import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import 'app_card.dart';
import 'app_icon_box.dart';

/// A cell of the "+" sheet (OFAR's quick actions).
class QuickActionCell extends StatelessWidget {
  const QuickActionCell({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
    super.key,
  });

  /// Keeps the cells close to square on regular phones.
  static const minHeight = 100.0;

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: minHeight),
    child: AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.md,
      ),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIconBox(icon: icon, color: color, background: background),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    ),
  );
}
