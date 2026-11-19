import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/expense_category_text.dart';
import '../models/expense_category.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../services/store_service.dart';
import '../viewmodels/expenses_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/async_state_view.dart';
import '../widgets/expense_category_icon.dart';
import '../widgets/figure_card.dart';
import '../widgets/load_more_button.dart';
import '../widgets/options_sheet.dart';
import '../widgets/record_tile.dart';
import 'expense_form_view.dart';

/// Expenses (`GET /api/expenses`): filter by store, category and dates, the
/// total of the filter, newest first, page by page. Tap one to edit or
/// delete it.
class ExpensesView extends StatelessWidget {
  const ExpensesView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => ExpensesViewModel(
      context.read<ExpenseService>(),
      context.read<StoreService>(),
    )..load(),
    child: const _ExpensesScreen(),
  );
}

class _ExpensesScreen extends StatelessWidget {
  const _ExpensesScreen();

  Future<void> _openForm(BuildContext context, {ExpenseModel? expense}) async {
    final vm = context.read<ExpensesViewModel>();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ExpenseFormView(initial: expense)),
    );
    if (saved ?? false) await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<ExpensesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navExpenses),
        actions: [
          IconButton(
            tooltip: l10n.actionNewExpense,
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: AsyncStateView(
          isLoading: vm.isLoading,
          error: vm.error,
          hasData: vm.hasData,
          onRetry: vm.load,
          isEmpty: vm.items.isEmpty && !vm.isFiltered,
          empty: AppEmptyView(
            icon: Icons.receipt_long_outlined,
            title: l10n.expensesEmptyTitle,
            message: l10n.expensesEmptyMessage,
            actionLabel: l10n.actionNewExpense,
            onAction: () => _openForm(context),
          ),
          builder: (context) => _ExpensesList(
            vm: vm,
            onOpen: (expense) => _openForm(context, expense: expense),
          ),
        ),
      ),
    );
  }
}

class _ExpensesList extends StatelessWidget {
  const _ExpensesList({required this.vm, required this.onOpen});

  final ExpensesViewModel vm;
  final ValueChanged<ExpenseModel> onOpen;

  Future<void> _pickStore(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showOptionsSheet<String>(
      context,
      title: l10n.fieldStore,
      selected: vm.storeId ?? '',
      options: [
        ('', l10n.salesAllStores),
        for (final s in vm.stores) (s.id, s.name),
      ],
    );
    if (picked == null) return;
    await vm.setFilter(
      storeId: picked.isEmpty ? null : picked,
      category: vm.category,
      startDate: vm.startDate,
      endDate: vm.endDate,
    );
  }

  Future<void> _pickCategory(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showOptionsSheet<String>(
      context,
      title: l10n.fieldCategory,
      selected: vm.category?.json ?? '',
      options: [
        ('', l10n.expensesAllCategories),
        for (final c in ExpenseCategory.values)
          (c.json, expenseCategoryText(l10n, c)),
      ],
    );
    if (picked == null) return;
    await vm.setFilter(
      storeId: vm.storeId,
      category: picked.isEmpty ? null : ExpenseCategory.fromJson(picked),
      startDate: vm.startDate,
      endDate: vm.endDate,
    );
  }

  Future<void> _pickDates(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: vm.startDate == null || vm.endDate == null
          ? null
          : DateTimeRange(start: vm.startDate!, end: vm.endDate!),
    );
    if (range == null) return;
    await vm.setFilter(
      storeId: vm.storeId,
      category: vm.category,
      startDate: range.start,
      endDate: range.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final storeName = vm.storeId == null
        ? l10n.salesAllStores
        : vm.stores
                  .where((s) => s.id == vm.storeId)
                  .map((s) => s.name)
                  .firstOrNull ??
              l10n.salesAllStores;
    final dates = vm.startDate == null || vm.endDate == null
        ? l10n.salesAllDates
        : '${context.formatShortDate(vm.startDate!)} – '
              '${context.formatShortDate(vm.endDate!)}';
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.xxxl,
      ),
      children: [
        AppPickerField(
          label: l10n.fieldStore,
          value: storeName,
          leading: const Icon(Icons.storefront_outlined),
          onTap: () => _pickStore(context),
        ),
        const SizedBox(height: AppSpacing.md),
        AppPickerField(
          label: l10n.fieldCategory,
          value: vm.category == null
              ? l10n.expensesAllCategories
              : expenseCategoryText(l10n, vm.category!),
          leading: const Icon(Icons.category_outlined),
          onTap: () => _pickCategory(context),
        ),
        const SizedBox(height: AppSpacing.md),
        AppPickerField(
          label: l10n.fieldPeriod,
          value: dates,
          leading: const Icon(Icons.date_range_outlined),
          onTap: () => _pickDates(context),
        ),
        if (vm.isFiltered)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: vm.clearFilter,
              child: Text(l10n.salesClearFilter),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        FigureCard(
          label: l10n.expensesTotal,
          value: context.money(vm.totalAmount ?? 0),
          valueColor: p.error,
          caption: l10n.expensesCount(vm.total),
        ),
        const SizedBox(height: AppSpacing.md),
        if (vm.items.isEmpty)
          AppCard(
            child: Text(
              l10n.expensesNothingFound,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                for (final expense in vm.items)
                  RecordTile(
                    icon: expenseCategoryIcon(expense.category),
                    iconColor: p.error,
                    iconBackground: p.errorLight,
                    title: expenseCategoryText(l10n, expense.category),
                    subtitle: [
                      context.formatDate(expense.expenseDate),
                      expense.storeName ?? l10n.expenseWholeBusiness,
                      if (expense.description != null) expense.description!,
                    ].join(' · '),
                    value: context.money(-expense.amount, signed: true),
                    valueColor: p.error,
                    onTap: () => onOpen(expense),
                  ),
              ],
            ),
          ),
        if (vm.hasMore)
          LoadMoreButton(
            label: l10n.commonShowMore,
            isLoading: vm.isLoadingMore,
            onPressed: vm.loadMore,
          ),
      ],
    );
  }
}
