import 'package:flutter/material.dart';

/// A small rounded status label (OFAR's status badge): one line, shrunk
/// rather than broken.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.color,
    required this.background,
    super.key,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(100),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    ),
  );
}
