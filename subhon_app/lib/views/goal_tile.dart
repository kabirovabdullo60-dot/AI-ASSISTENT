import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/savings_goal_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/savings_goal_card.dart';
import 'savings_goals_view.dart';

/// One goal from the view model (also on home).
class GoalTile extends StatelessWidget {
  const GoalTile({required this.goal, super.key});

  final SavingsGoalModel goal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<PersonalFinanceViewModel>();
    final currency = vm.currencyOf(goal.accountId);
    String money(double v) => context.money(v, currency: currency);
    final saved = vm.goalSaved(goal);
    final left = (goal.target - saved).clamp(0, double.infinity).toDouble();
    final deadline = goal.deadline;
    String subtitle;
    if (left <= 0) {
      subtitle = l10n.goalReached;
    } else if (deadline == null) {
      subtitle = l10n.goalLeftNoDate(money(left));
    } else {
      final today = vm.today;
      final months =
          (deadline.year - today.year) * 12 + deadline.month - today.month;
      subtitle = l10n.goalLeft(money(left), context.formatDate(deadline));
      if (months > 0) {
        subtitle += ' · ${l10n.goalPerMonth(money(left / months))}';
      }
    }
    return SavingsGoalCard(
      name: goal.name,
      progress: vm.goalProgress(goal),
      savedText: l10n.goalSaved(money(saved), money(goal.target)),
      subtitle: subtitle,
      topUpLabel: l10n.goalTopUp,
      onTap: () => SavingsGoalsView.openForm(context, goal: goal),
      onTopUp: () => SavingsGoalsView.topUp(context, goal),
    );
  }
}
