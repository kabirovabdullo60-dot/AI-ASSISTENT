import 'package:flutter/material.dart';

import '../core/utils/format.dart';
import '../models/kpi_model.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({super.key, required this.kpi});

  final KpiModel kpi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = kpi.changePercent;
    final changeColor = kpi.isGoodChange ? Colors.green.shade600 : theme.colorScheme.error;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kpi.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                kpi.displayValue,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (change != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(change >= 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: changeColor),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      formatPercent(change),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(color: changeColor),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
