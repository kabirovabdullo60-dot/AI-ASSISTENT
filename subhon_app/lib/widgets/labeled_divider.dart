import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';

class LabeledDivider extends StatelessWidget {
  const LabeledDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Text(label, style: Theme.of(context).textTheme.bodySmall),
      ),
      const Expanded(child: Divider()),
    ],
  );
}
