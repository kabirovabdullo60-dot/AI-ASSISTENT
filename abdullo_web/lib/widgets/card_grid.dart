import 'package:flutter/material.dart';

/// Lays out children in [columns] equal columns that wrap to new rows.
class CardGrid extends StatelessWidget {
  const CardGrid({
    super.key,
    required this.columns,
    required this.children,
    this.spacing = 12,
    this.equalHeight = false,
  });

  final int columns;

  /// Every card in a row as tall as the tallest one (cards then stretch, so their
  /// bottom rows line up).
  final bool equalHeight;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        if (equalHeight) {
          return Column(
            children: [
              for (var start = 0; start < children.length; start += columns) ...[
                if (start > 0) SizedBox(height: spacing),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = start; i < start + columns; i++) ...[
                        if (i > start) SizedBox(width: spacing),
                        SizedBox(width: width, child: i < children.length ? children[i] : null),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        }
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final child in children) SizedBox(width: width, child: child)],
        );
      },
    );
  }
}
