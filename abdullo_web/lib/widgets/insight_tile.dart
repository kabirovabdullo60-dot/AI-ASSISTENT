import 'package:flutter/material.dart';

import '../models/insight_model.dart';

class InsightTile extends StatelessWidget {
  const InsightTile({super.key, required this.insight});

  final InsightModel insight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (IconData icon, Color color) = switch (insight.level) {
      InsightLevel.success => (Icons.trending_up, Colors.green.shade600),
      InsightLevel.warning => (Icons.warning_amber_rounded, Colors.orange.shade700),
      InsightLevel.info => (Icons.lightbulb_outline, scheme.primary),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color),
      ),
      title: Text(insight.title),
      subtitle: Text(insight.description),
    );
  }
}
