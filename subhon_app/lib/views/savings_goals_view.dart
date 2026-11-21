import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/money_transaction_kind.dart';
import '../models/savings_goal_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/app_button.dart';
import 'goal_tile.dart';
import 'money_transaction_form_view.dart';
import 'savings_goal_form_view.dart';

/// "Цели накоплений": each goal with its progress; add, edit, top up.
class SavingsGoalsView extends StatelessWidget {
  const SavingsGoalsView({super.key});

  static Future<void> openForm(
    BuildContext context, {
    SavingsGoalModel? goal,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PersonalFinanceViewModel>(),
        child: SavingsGoalFormView(initial: goal),
      ),
    ),
  );

  /// A transfer from another account into the goal's account.
  static Future<void> topUp(BuildContext context, SavingsGoalModel goal) {
    final vm = context.read<PersonalFinanceViewModel>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: MoneyTransactionFormView(
            kind: MoneyTransactionKind.transfer,
            toAccountId: goal.accountId,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<PersonalFinanceViewModel>();
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        title: Text(l10n.goalTitle),
        actions: [
          IconButton(
            tooltip: l10n.goalNew,
            onPressed: () => openForm(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          if (vm.goals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    l10n.goalEmpty,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: l10n.goalNew,
                    icon: Icons.add_rounded,
                    onPressed: () => openForm(context),
                  ),
                ],
              ),
            ),
          for (final g in vm.goals) ...[
            GoalTile(goal: g),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
