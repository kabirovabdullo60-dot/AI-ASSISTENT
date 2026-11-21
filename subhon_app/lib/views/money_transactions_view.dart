import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/money_excel.dart';
import '../l10n/money_text.dart';
import '../models/money_category.dart';
import '../models/money_transaction_kind.dart';
import '../models/money_transaction_model.dart';
import '../services/file_share_service.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/money_transaction_tile.dart';
import '../widgets/options_sheet.dart';
import '../widgets/search_field.dart';
import 'money_transaction_form_view.dart';

/// Every personal operation grouped by day ("19 ноября, четверг"), with a
/// search (note, category, account), filters by type, account and
/// category, the found income and expenses, and "В Excel". Tap one to
/// edit or delete it.
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

  Future<void> _excel(
    BuildContext context,
    List<MoneyTransactionModel> list,
  ) async {
    final vm = context.read<PersonalFinanceViewModel>();
    final l10n = context.l10n;
    final (income, expense) = vm.totals(list);
    final bytes = operationsToExcel(
      list,
      l10n,
      account: vm.account,
      income: income,
      expense: expense,
    );
    final d = vm.today;
    await context.read<FileShareService>().share(
      bytes: bytes,
      fileName:
          'operations_${d.year}-${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}.xlsx',
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Future<void> _pickAccount(BuildContext context) async {
    final vm = context.read<PersonalFinanceViewModel>();
    final l10n = context.l10n;
    final picked = await showOptionsSheet<String>(
      context,
      title: l10n.pfAccount,
      selected: vm.accountFilter ?? '',
      options: [
        ('', l10n.opsAllAccounts),
        for (final a in vm.accounts) (a.id, a.name),
      ],
    );
    if (picked != null) vm.setAccountFilter(picked.isEmpty ? null : picked);
  }

  Future<void> _pickCategory(BuildContext context) async {
    final vm = context.read<PersonalFinanceViewModel>();
    final l10n = context.l10n;
    final kind = vm.kindFilter;
    final picked = await showOptionsSheet<String>(
      context,
      title: l10n.fieldCategory,
      selected: vm.categoryFilter?.name ?? '',
      options: [
        ('', l10n.opsAllCategories),
        for (final c in MoneyCategory.values)
          if (kind == null || c.income == (kind == MoneyTransactionKind.income))
            (c.name, moneyCategoryText(l10n, c)),
      ],
    );
    if (picked != null) {
      vm.setCategoryFilter(
        picked.isEmpty ? null : MoneyCategory.fromName(picked),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<PersonalFinanceViewModel>();
    final list = vm.filtered(categoryText: (c) => moneyCategoryText(l10n, c));
    final days = vm.groupByDay(list);
    final (income, expense) = vm.totals(list);
    final account = vm.account(vm.accountFilter);
    final category = vm.categoryFilter;
    Widget kindChip(MoneyTransactionKind? kind, String label) => ChoiceChip(
      label: Text(label),
      selected: vm.kindFilter == kind,
      showCheckmark: false,
      onSelected: (_) => vm.setKindFilter(kind),
    );
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        title: Text(l10n.pfOperations),
        actions: [
          if (list.isNotEmpty)
            IconButton(
              tooltip: l10n.opsExcel,
              onPressed: () => _excel(context, list),
              icon: const Icon(Icons.file_download_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.xxxl * 2,
        ),
        children: [
          SearchField(
            hint: l10n.opsSearch,
            clearTooltip: l10n.opsClear,
            initialValue: vm.query,
            onChanged: vm.setQuery,
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                kindChip(null, l10n.opsAll),
                const SizedBox(width: AppSpacing.xs),
                kindChip(MoneyTransactionKind.expense, l10n.opsExpenses),
                const SizedBox(width: AppSpacing.xs),
                kindChip(MoneyTransactionKind.income, l10n.opsIncome),
                const SizedBox(width: AppSpacing.xs),
                kindChip(MoneyTransactionKind.transfer, l10n.opsTransfers),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              ActionChip(
                avatar: const Icon(Icons.account_balance_wallet_outlined),
                label: Text(account?.name ?? l10n.opsAllAccounts),
                onPressed: () => _pickAccount(context),
              ),
              if (vm.kindFilter != MoneyTransactionKind.transfer)
                ActionChip(
                  avatar: Icon(
                    category == null
                        ? Icons.category_outlined
                        : moneyCategoryIcon(category),
                  ),
                  label: Text(
                    category == null
                        ? l10n.opsAllCategories
                        : moneyCategoryText(l10n, category),
                  ),
                  onPressed: () => _pickCategory(context),
                ),
              if (vm.isFiltered)
                ActionChip(
                  avatar: const Icon(Icons.close_rounded),
                  label: Text(l10n.opsReset),
                  onPressed: vm.clearFilters,
                ),
            ],
          ),
          if (vm.isFiltered && list.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                l10n.opsFound(
                  list.length,
                  context.money(income),
                  context.money(expense),
                ),
                style: theme.textTheme.bodySmall,
              ),
            ),
          if (days.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                vm.isFiltered ? l10n.opsNothing : l10n.pfNoOperations,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
          for (final (day, items) in days) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                context.formatDayHeader(day),
                style: theme.textTheme.titleSmall,
              ),
            ),
            for (final t in items) ...[
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
