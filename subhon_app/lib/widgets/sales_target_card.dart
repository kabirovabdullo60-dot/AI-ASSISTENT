import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/target_period.dart';
import 'app_feedback.dart';
import 'target_amount_sheet.dart';
import 'target_progress_card.dart';

/// A weekly or monthly sales target with its progress; tap to set or
/// change it in a sheet. [onSave] sends the new amount and returns the
/// error, if any.
class SalesTargetCard extends StatelessWidget {
  const SalesTargetCard({
    required this.period,
    required this.sales,
    required this.target,
    required this.hint,
    required this.onSave,
    super.key,
  });

  final TargetPeriod period;
  final double sales;

  /// `null`: not set yet.
  final double? target;

  /// Who the target is for, shown in the sheet.
  final String hint;
  final Future<Object?> Function(double amount) onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final goal = target;
    return TargetProgressCard(
      label: period == TargetPeriod.week ? l10n.targetWeek : l10n.targetMonth,
      sales: sales,
      salesText: context.money(sales),
      target: goal,
      targetText: goal == null ? null : context.money(goal),
      percentText: goal == null || goal <= 0
          ? null
          : l10n.targetDone(context.percent(sales / goal * 100)),
      emptyText: l10n.targetNotSet,
      onTap: () => showAppBottomSheet<void>(
        context,
        title: period == TargetPeriod.week
            ? l10n.targetSheetTitleWeek
            : l10n.targetSheetTitleMonth,
        builder: (_) =>
            TargetAmountSheet(hint: hint, current: goal, onSave: onSave),
      ),
    );
  }
}
