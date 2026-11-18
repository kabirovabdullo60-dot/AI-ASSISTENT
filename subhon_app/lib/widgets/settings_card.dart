import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import 'app_card.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Column(children: children),
  );
}
