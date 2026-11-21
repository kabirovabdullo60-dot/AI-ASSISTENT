import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Grey pill with tabs: "Today | This Week | This Month".
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelect,
    this.icons = const {},
    this.dark = true,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  /// Optional icon per tab index.
  final Map<int, IconData> icons;

  /// Selected tab navy (true) or white (false).
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < labels.length; i++)
              Material(
                color: i == selected ? (dark ? AppColors.teal : AppColors.card) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                elevation: i == selected && !dark ? 1 : 0,
                child: InkWell(
                  key: Key('tab-${labels[i]}'),
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icons[i] != null) ...[
                          Icon(icons[i], size: 14, color: i == selected && dark ? Colors.white : AppColors.ink),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: i == selected ? FontWeight.w700 : FontWeight.w500,
                            color: i == selected && dark ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
