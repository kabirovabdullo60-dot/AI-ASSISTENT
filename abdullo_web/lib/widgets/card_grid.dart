import 'package:flutter/material.dart';

/// Lays out children in [columns] equal columns that wrap to new rows.
class CardGrid extends StatelessWidget {
  const CardGrid({super.key, required this.columns, required this.children, this.spacing = 12});

  final int columns;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final child in children) SizedBox(width: width, child: child)],
        );
      },
    );
  }
}
