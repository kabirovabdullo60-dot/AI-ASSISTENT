import 'package:flutter/material.dart';

import '../core/utils/format.dart';
import '../models/sales_point_model.dart';

/// Simple bar chart; the last bar (current month) is highlighted.
class SalesBarChart extends StatelessWidget {
  const SalesBarChart({super.key, required this.points, this.height = 220});

  final List<SalesPointModel> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No data yet')),
      );
    }

    final theme = Theme.of(context);
    final max = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    const labelSpace = 44.0;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < points.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(formatCompact(points[i].value), style: theme.textTheme.labelSmall),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: max == 0 ? 0 : (height - labelSpace) * points[i].value / max,
                      decoration: BoxDecoration(
                        color: i == points.length - 1
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withValues(alpha: 0.35),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(points[i].label, style: theme.textTheme.labelMedium),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
