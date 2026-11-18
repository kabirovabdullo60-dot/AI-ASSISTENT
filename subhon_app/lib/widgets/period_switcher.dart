import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import 'app_card.dart';

/// "‹ Ноябрь 2026 ›": the month (or year) a screen shows.
class PeriodSwitcher extends StatelessWidget {
  const PeriodSwitcher({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
    super.key,
  });

  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousTooltip;
  final String nextTooltip;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    child: Row(
      children: [
        IconButton(
          tooltip: previousTooltip,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        IconButton(
          tooltip: nextTooltip,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    ),
  );
}
