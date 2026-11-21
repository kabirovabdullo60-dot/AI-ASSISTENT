import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Compact filter button with a popup list, e.g. "All Status (5 Active, 1 Inactive) ▾".
class DropdownChip<T> extends StatelessWidget {
  const DropdownChip({
    super.key,
    required this.label,
    required this.items,
    required this.onSelected,
    this.icon,
    this.value,
  });

  final String label;
  final IconData? icon;
  final T? value;

  /// (value, text) pairs.
  final List<(T, String)> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: '',
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (_) => [for (final (v, text) in items) PopupMenuItem(value: v, child: Text(text))],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: AppColors.ink), const SizedBox(width: 6)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
