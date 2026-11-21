import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// A small figure with its label (e.g. "Expenses 1,200 TJS"): a white card with a 1px edge,
/// the label in grey over the value in ink with tabular digits. The icon, if any, stays grey.
class MiniStatTile extends StatelessWidget {
  const MiniStatTile({super.key, required this.label, required this.value, required this.icon, this.iconColor});

  final String label;
  final String value;
  final IconData icon;

  /// Kept for callers; the icon is grey (colour belongs to data, not to decoration).
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFeatures: AppTheme.numbers),
                ),
              ],
            ),
          ),
          Icon(icon, size: 16, color: AppColors.muted),
        ],
      ),
    );
  }
}
