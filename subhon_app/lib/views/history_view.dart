import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../viewmodels/history_range.dart';
import '../viewmodels/history_view_model.dart';
import '../widgets/async_state_view.dart';
import '../widgets/load_more_button.dart';
import '../widgets/operation_card.dart';
import '../widgets/search_field.dart';
import 'expenses_view.dart';
import 'statements_view.dart';

/// The "История" tab, laid out like a bank's history: "Расходы за <месяц>"
/// (can be hidden) next to "Выписка", period chips (all, today, yesterday,
/// week), then the operations grouped by day — store or employee, what
/// happened, the amount. 🔍 searches the loaded operations.
class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  bool _searching = false;

  Future<void> _open(Widget screen) async {
    final vm = context.read<HistoryViewModel>();
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
    await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<HistoryViewModel>();
    final days = vm.days;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        title: Text(l10n.activityHistory),
        actions: [
          IconButton(
            tooltip: l10n.historySearch,
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) vm.setSearch('');
            },
            icon: Icon(
              _searching ? Icons.close_rounded : Icons.search_rounded,
              color: p.primary,
            ),
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
          builder: (context) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xxxl * 2,
            ),
            children: [
              if (_searching) ...[
                SearchField(
                  hint: l10n.historySearchHint,
                  clearTooltip: l10n.commonClear,
                  onChanged: vm.setSearch,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _ExpensesCard(
                        vm: vm,
                        onOpen: () => _open(const ExpensesView()),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 3,
                      child: _Tile(
                        onTap: () => _open(const StatementsView()),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: p.primary,
                              size: 30,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              l10n.historyStatement,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    for (final (range, label) in [
                      (HistoryRange.all, l10n.historyAll),
                      (HistoryRange.today, l10n.periodToday),
                      (HistoryRange.yesterday, l10n.historyYesterday),
                      (HistoryRange.week, l10n.historyWeek),
                    ]) ...[
                      ChoiceChip(
                        label: Text(label),
                        selected: vm.range == range,
                        showCheckmark: false,
                        onSelected: (_) => vm.setRange(range),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (days.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Text(
                    l10n.historyNothing,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              for (final (day, operations) in days) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                  ),
                  child: Text(
                    context.formatDayHeader(day),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final op in operations) ...[
                  OperationCard(operation: op),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
              if (vm.hasMore)
                LoadMoreButton(
                  label: l10n.commonShowMore,
                  isLoading: vm.isLoadingMore,
                  onPressed: vm.loadMore,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Расходы за <месяц>": the amount (with an eye to hide it), a bar of how
/// much of the sales went on expenses; tap to open the expenses.
class _ExpensesCard extends StatelessWidget {
  const _ExpensesCard({required this.vm, required this.onOpen});

  final HistoryViewModel vm;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = context.palette;
    final month = vm.month;
    final expenses = month?.expensesTotal ?? 0;
    final sales = month?.salesTotal ?? 0;
    final share = sales <= 0 ? 0.0 : (expenses / sales).clamp(0.0, 1.0);
    final now = month?.period.startDate ?? DateTime.now();
    return _Tile(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.historyExpensesFor(context.monthName(now)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.textSecondary),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    vm.amountHidden ? '••••• TJS' : context.money(expenses),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              IconButton(
                tooltip: vm.amountHidden
                    ? l10n.historyShowAmount
                    : l10n.historyHideAmount,
                visualDensity: VisualDensity.compact,
                onPressed: vm.toggleAmount,
                icon: Icon(
                  vm.amountHidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: p.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(99)),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 8,
              backgroundColor: p.surfaceMuted,
              color: p.error,
            ),
          ),
          if (sales > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.historyOfSales(context.percent(share * 100)),
              style: theme.textTheme.labelSmall?.copyWith(
                color: p.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A big rounded white tile.
class _Tile extends StatelessWidget {
  const _Tile({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.palette.surface,
    borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    ),
  );
}
