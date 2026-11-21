import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/money_text.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/notifications_view_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/money_transaction_tile.dart';
import '../widgets/notification_bell.dart';
import '../widgets/period_switcher.dart';
import '../widgets/section_header.dart';
import '../widgets/share_bar_row.dart';
import '../widgets/summary_card.dart';
import 'goal_tile.dart';
import 'money_accounts_view.dart';
import 'money_transactions_view.dart';
import 'quick_entry_view.dart';
import 'recurring_payment_tile.dart';
import 'recurring_payments_view.dart';
import 'savings_goals_view.dart';

/// Home of the personal accountant: my money on all accounts with this
/// month's income and expenses, the accounts (sideways), coming regular
/// payments, expenses by category for a month, the latest operations, and
/// "Мой бизнес" — the shop's dashboard when there is a store, an
/// invitation to add one otherwise.
class PersonalHomeView extends StatefulWidget {
  const PersonalHomeView({
    required this.hasBusiness,
    required this.onOpenBusiness,
    required this.onAddStore,
    required this.onOpenNotifications,
    super.key,
  });

  final bool hasBusiness;
  final VoidCallback onOpenBusiness;
  final VoidCallback onAddStore;
  final VoidCallback onOpenNotifications;

  @override
  State<PersonalHomeView> createState() => _PersonalHomeViewState();
}

class _PersonalHomeViewState extends State<PersonalHomeView> {
  @override
  void initState() {
    super.initState();
    // The first time: a cash wallet, so money can be written down at once.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vm = context.read<PersonalFinanceViewModel>();
      final name = context.l10n.pfKindCash;
      if (!vm.hasData) await vm.load();
      await vm.ensureDefaultAccount(name);
    });
  }

  Future<void> _push(Widget page) {
    final vm = context.read<PersonalFinanceViewModel>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(value: vm, child: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<PersonalFinanceViewModel>();
    final notifications = context.watch<NotificationsViewModel>();
    final upcoming = vm.upcoming();
    final byCategory = vm.monthExpensesByCategory;
    final monthExpense = vm.monthExpense;
    final recent = vm.transactions.take(5).toList();
    const gap = SizedBox(height: AppSpacing.md);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHome),
        actions: [
          if (widget.hasBusiness)
            NotificationBell(
              unread: notifications.unreadCount,
              tooltip: l10n.notificationsTooltip,
              onPressed: widget.onOpenNotifications,
            ),
        ],
      ),
      body: !vm.hasData
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xxxl * 2,
              ),
              children: [
                SummaryCard(
                  title: l10n.pfTotalBalance,
                  value: context.money(vm.totalBalance),
                  parts: [
                    (l10n.phMonthIncome, context.money(vm.monthIncome)),
                    (l10n.phMonthExpense, context.money(monthExpense)),
                  ],
                ),
                if (vm.hasForeign)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      vm.ratesMissing ? l10n.pfRatesMissing : l10n.pfInTjsNote,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                Material(
                  color: p.surface,
                  shape: StadiumBorder(side: BorderSide(color: p.border)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _push(const QuickEntryView()),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.xs,
                        AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.edit_note_rounded, color: p.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              l10n.qeButton,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: p.textSecondary,
                              ),
                            ),
                          ),
                          IconButton.filled(
                            tooltip: l10n.qeSpeak,
                            onPressed: () => _push(
                              const QuickEntryView(listenAtStart: true),
                            ),
                            icon: const Icon(Icons.mic_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SectionHeader(
                  title: l10n.pfAccounts,
                  actionLabel: l10n.homeShowAllStores,
                  onAction: () => _push(const MoneyAccountsView()),
                ),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: vm.accounts.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, i) {
                      if (i == vm.accounts.length) {
                        return SizedBox(
                          width: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Tooltip(
                                message: l10n.phAddAccount,
                                child: Material(
                                  color: p.primary,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () =>
                                        MoneyAccountsView.openForm(context),
                                    child: SizedBox.square(
                                      dimension: 46,
                                      child: Icon(
                                        Icons.add_rounded,
                                        color: p.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                l10n.phAddAccount,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: p.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final a = vm.accounts[i];
                      return SizedBox(
                        width: 170,
                        child: Material(
                          color: p.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.lgAll,
                            side: BorderSide(color: p.border),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () =>
                                MoneyAccountsView.openForm(context, account: a),
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        accountKindIcon(a.kind),
                                        size: 18,
                                        color: p.primary,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          a.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.labelLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      context.money(
                                        vm.balance(a.id),
                                        currency: a.currency,
                                      ),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (vm.goals.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: l10n.goalTitle,
                    actionLabel: l10n.homeShowAllStores,
                    onAction: () => _push(const SavingsGoalsView()),
                  ),
                  for (final g in vm.goals.take(2)) ...[
                    GoalTile(goal: g),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
                if (upcoming.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: l10n.pfUpcoming,
                    actionLabel: l10n.homeShowAllStores,
                    onAction: () => _push(const RecurringPaymentsView()),
                  ),
                  for (final r in upcoming) ...[
                    RecurringPaymentTile(payment: r),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(title: l10n.pfByCategory),
                PeriodSwitcher(
                  label: context.monthYear(vm.month.month, vm.month.year),
                  previousTooltip: l10n.periodPrevious,
                  nextTooltip: l10n.periodNext,
                  onPrevious: () => vm.shiftMonth(-1),
                  onNext: vm.isCurrentMonth ? null : () => vm.shiftMonth(1),
                ),
                gap,
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(color: p.border),
                  ),
                  child: byCategory.isEmpty
                      ? Text(
                          l10n.pfNoExpensesMonth,
                          style: theme.textTheme.bodySmall,
                        )
                      : Column(
                          children: [
                            for (final (i, (cat, sum))
                                in byCategory.indexed) ...[
                              if (i > 0) gap,
                              ShareBarRow(
                                icon: moneyCategoryIcon(cat),
                                label: moneyCategoryText(l10n, cat),
                                value: context.money(sum),
                                share: monthExpense == 0
                                    ? 0
                                    : sum / monthExpense,
                                shareText: context.percent(
                                  monthExpense == 0
                                      ? 0
                                      : sum / monthExpense * 100,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _BusinessCard(
                  hasBusiness: widget.hasBusiness,
                  onOpen: widget.onOpenBusiness,
                  onAddStore: widget.onAddStore,
                ),
                if (recent.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(
                    title: l10n.pfRecent,
                    actionLabel: l10n.homeShowAllStores,
                    onAction: () => _push(const MoneyTransactionsView()),
                  ),
                  for (final t in recent) ...[
                    MoneyTransactionTile(
                      transaction: t,
                      account: vm.account(t.accountId),
                      toAccount: vm.account(t.toAccountId),
                      onTap: () => MoneyTransactionsView.openForm(
                        context,
                        transaction: t,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.pfLocalNote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
    );
  }
}

/// "Мой бизнес": the shop's figures and "Открыть", or an invitation to add
/// a store.
class _BusinessCard extends StatelessWidget {
  const _BusinessCard({
    required this.hasBusiness,
    required this.onOpen,
    required this.onAddStore,
  });

  final bool hasBusiness;
  final VoidCallback onOpen;
  final VoidCallback onAddStore;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final dashboard = context.watch<DashboardViewModel>().dashboard;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: p.primaryLight,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storefront_outlined, color: p.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  hasBusiness ? l10n.phMyBusiness : l10n.phStartBusinessTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hasBusiness && dashboard != null
                ? l10n.phBusinessToday(
                    context.money(dashboard.todaySales),
                    context.money(dashboard.monthProfit, signed: true),
                  )
                : l10n.phStartBusinessMessage,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: hasBusiness ? l10n.phOpen : l10n.phAddStore,
            icon: hasBusiness
                ? Icons.arrow_forward_rounded
                : Icons.add_business_outlined,
            onPressed: hasBusiness ? onOpen : onAddStore,
          ),
        ],
      ),
    );
  }
}
