import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/money_transaction_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/money_transaction_tile.dart';
import 'money_transaction_form_view.dart';

/// Every personal operation grouped by day ("19 ноября, четверг"); tap
/// one to edit or delete it.
class MoneyTransactionsView extends StatelessWidget {
  const MoneyTransactionsView({super.key});

  static Future<void> openForm(
    BuildContext context, {
    MoneyTransactionModel? transaction,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PersonalFinanceViewModel>(),
        child: MoneyTransactionFormView(initial: transaction),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<PersonalFinanceViewModel>();
    final days = vm.days;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        title: Text(l10n.pfOperations),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxxl * 2,
        ),
        children: [
          if (days.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                l10n.pfNoOperations,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
          for (final (day, list) in days) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                context.formatDayHeader(day),
                style: theme.textTheme.titleSmall,
              ),
            ),
            for (final t in list) ...[
              MoneyTransactionTile(
                transaction: t,
                account: vm.account(t.accountId),
                toAccount: vm.account(t.toAccountId),
                onTap: () => openForm(context, transaction: t),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ],
      ),
    );
  }
}
