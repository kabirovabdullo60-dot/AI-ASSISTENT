import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

/// OFAR's period chips (Сегодня · Неделя · Месяц).
class PeriodChips<T> extends StatelessWidget {
  const PeriodChips({
    required this.values,
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<T> values;
  final String Function(T value) label;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (i, value) in values.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              label: Text(label(value)),
              selected: value == selected,
              onSelected: (_) => onSelected(value),
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: value == selected ? p.primary : p.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
