import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/l10n.dart';
import 'status_badge.dart';

/// Работает / Не работает (stores and employees: ACTIVE / INACTIVE).
class ActiveStatusBadge extends StatelessWidget {
  const ActiveStatusBadge({required this.active, super.key});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return active
        ? StatusBadge(
            label: context.l10n.statusActive,
            color: p.success,
            background: p.successLight,
          )
        : StatusBadge(
            label: context.l10n.statusInactive,
            color: p.textSecondary,
            background: p.surfaceMuted,
          );
  }
}
