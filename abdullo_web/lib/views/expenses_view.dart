import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/expense_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/expenses_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/app_table.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/mini_stat_tile.dart';
import '../widgets/motion/shimmer_sweep.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';
import 'expense_form_dialog.dart';
import '../core/motion/app_dialog.dart';

/// Expenses & profit — /api/expenses (CRUD) + /api/reports/profit.
class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  Future<void> _delete(BuildContext context, ExpenseModel e) async {
    final tr = context.l10n;
    final ok = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.deleteExpenseTitle),
        content: Text(tr.deleteExpenseBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr.cancel)),
          FilledButton(
            key: const Key('confirm-delete-expense'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final dashboard = context.read<DashboardViewModel>();
    final error = await context.read<ExpensesViewModel>().delete(e.id);
    if (error == null) dashboard.load();
    if (context.mounted) showResult(context, error, success: tr.expenseDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<ExpensesViewModel>();
    final query = context.select<HomeViewModel, String>((h) => h.query);
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    return AsyncContent(
      hasData: vm.hasData,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) {
        final list = vm.filtered(query);
        final p = vm.profit;
        final profitColor = (p?.grossProfit ?? 0) >= 0 ? AppColors.green : AppColors.red;
        return PageBody(
          title: tr.navExpenses,
          subtitle: tr.expensesSubtitle,
          actions: [
            ShimmerSweep(
              child: FilledButton.icon(
                key: const Key('add-expense'),
                onPressed: () => ExpenseFormDialog.show(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(tr.addExpense),
              ),
            ),
          ],
          children: [
            if (p != null)
              LayoutBuilder(
                builder: (context, c) => CardGrid(
                  columns: c.maxWidth >= 900 ? 4 : (c.maxWidth >= 620 ? 2 : 1),
                  children: [
                    MiniStatTile(
                      label: tr.activitySales,
                      value: cur.format(p.salesTotal),
                      icon: Icons.trending_up,
                      iconColor: AppColors.green,
                    ),
                    MiniStatTile(
                      label: tr.navExpenses,
                      value: cur.format(p.expensesTotal),
                      icon: Icons.request_quote_outlined,
                      iconColor: AppColors.orange,
                    ),
                    MiniStatTile(
                      label: tr.salaryDueLabel,
                      value: cur.format(p.salaryDue),
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    MiniStatTile(
                      key: const Key('profit-tile'),
                      label: p.marginPercent == null
                          ? tr.profitThisMonth
                          : '${tr.profitThisMonth} · ${formatPercent(p.marginPercent!)}',
                      value: cur.format(p.grossProfit),
                      icon: Icons.savings_outlined,
                      iconColor: profitColor,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SectionCard(
              title: tr.expenseList,
              subtitle: '${tr.expenseTotal}: ${cur.format(vm.total)}',
              trailing: PopupMenuButton<ExpenseCategory?>(
                key: const Key('expense-filter'),
                tooltip: tr.filter,
                icon: Icon(Icons.filter_list, color: vm.category == null ? AppColors.muted : AppColors.orange),
                onSelected: vm.setCategory,
                itemBuilder: (_) => [
                  PopupMenuItem(value: null, child: Text(tr.allCategories)),
                  for (final c in ExpenseCategory.values) PopupMenuItem(value: c, child: Text(tr.expenseCategory(c))),
                ],
              ),
              child: AppTable(
                key: const Key('expenses-table'),
                columns: [tr.expenseDate, tr.expenseCategoryLabel, tr.store, tr.description, tr.expenseAmount, ''],
                numeric: const {4},
                empty: tr.noExpenses,
                rows: [
                  for (final e in list)
                    [
                      Text(formatDate(e.expenseDate)),
                      Text(tr.expenseCategory(e.category), style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(e.storeName ?? tr.wholeBusiness),
                      Text(e.description ?? '—', style: TextStyle(color: AppColors.muted)),
                      Text(
                        '-${cur.format(e.amount)}',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.red),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            key: Key('edit-expense-${e.id}'),
                            tooltip: tr.edit,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => ExpenseFormDialog.show(context, expense: e),
                            icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.muted),
                          ),
                          IconButton(
                            key: Key('delete-expense-${e.id}'),
                            tooltip: tr.delete,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _delete(context, e),
                            icon: Icon(Icons.delete_outline, size: 18, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                ],
              ),
            ),
            if (p != null && p.byCategory.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: tr.byCategory,
                child: AppTable(
                  columns: [tr.expenseCategoryLabel, tr.expenseAmount],
                  numeric: const {1},
                  rows: [
                    for (final c in p.byCategory)
                      [
                        Text(tr.expenseCategory(c.category), style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(cur.format(c.total)),
                      ],
                  ],
                ),
              ),
            ],
            if (p != null && p.byStore.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: tr.profitByStore,
                child: AppTable(
                  key: const Key('profit-table'),
                  columns: [tr.store, tr.activitySales, tr.navExpenses, tr.salaryDueLabel, tr.profitLabel],
                  numeric: const {1, 2, 3, 4},
                  rows: [
                    for (final s in p.byStore)
                      [
                        Text(s.storeName ?? tr.wholeBusiness, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text(cur.format(s.sales)),
                        Text(cur.format(s.expenses)),
                        Text(cur.format(s.salaryDue)),
                        Text(
                          cur.format(s.profit),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: s.profit >= 0 ? AppColors.green : AppColors.red,
                          ),
                        ),
                      ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
