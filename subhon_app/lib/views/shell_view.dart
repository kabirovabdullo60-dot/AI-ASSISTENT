import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../services/activity_service.dart';
import '../models/notification_link.dart';
import '../services/notification_service.dart';
import '../services/payroll_service.dart';
import '../services/reports_service.dart';
import '../services/sales_service.dart';
import '../services/store_service.dart';
import '../viewmodels/history_view_model.dart';
import '../core/storage/debt_storage.dart';
import '../core/storage/personal_finance_storage.dart';
import '../models/money_transaction_kind.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/debts_view_model.dart';
import '../viewmodels/session_view_model.dart';
import '../viewmodels/notifications_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../viewmodels/reminder_planner.dart';
import '../services/reminder_service.dart';
import '../viewmodels/sales_view_model.dart';
import '../widgets/add_nav_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/assistant_fab.dart';
import '../widgets/bottom_nav_item.dart';
import '../widgets/quick_action_cell.dart';
import 'history_view.dart';
import 'chat_view.dart';
import 'debts_view.dart';
import 'employee_form_view.dart';
import 'expense_form_view.dart';
import 'home_view.dart';
import 'money_transaction_form_view.dart';
import 'money_transactions_view.dart';
import 'more_view.dart';
import 'notifications_view.dart';
import 'payroll_view.dart';
import 'personal_home_view.dart';
import 'quick_entry_view.dart';
import 'recurring_payments_view.dart';
import 'sale_form_view.dart';
import 'sales_view.dart';
import 'store_form_view.dart';
import 'stores_view.dart';

/// The app after login: a personal accountant first. Bottom bar:
/// Главная · Операции · [+] · Долги · Ещё. Home is "Мои финансы"; the
/// business (stores, sales, employees, salaries) shows up — on home, in
/// "+" and in "Ещё" — once there is a store.
class ShellView extends StatefulWidget {
  const ShellView({super.key});

  @override
  State<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<ShellView> {
  int _index = 0;

  late final _dashboard = DashboardViewModel(
    context.read<ReportsService>(),
    context.read<SalesService>(),
    context.read<StoreService>(),
    context.read<ActivityService>(),
  )..load();

  /// Created the first time the sales list is opened (it is no longer a
  /// tab).
  SalesViewModel? _salesVm;
  SalesViewModel get _sales => _salesVm ??= SalesViewModel(
    context.read<SalesService>(),
    context.read<StoreService>(),
  );

  /// Created the first time salaries are opened (they are no longer a tab).
  PayrollViewModel? _payrollVm;
  PayrollViewModel get _payroll =>
      _payrollVm ??= PayrollViewModel(context.read<PayrollService>());

  late final _debts = DebtsViewModel(
    context.read<DebtStorage>(),
    context.read<SessionViewModel>().user?.id,
  )..load();

  /// Created the first time the history is opened.
  HistoryViewModel? _historyVm;
  HistoryViewModel get _history => _historyVm ??= HistoryViewModel(
    context.read<ActivityService>(),
    context.read<ReportsService>(),
  );
  late final _notifications = NotificationsViewModel(
    context.read<NotificationService>(),
  )..load();

  /// The personal accountant (kept on the phone).
  late final _personal = PersonalFinanceViewModel(
    context.read<PersonalFinanceStorage>(),
    context.read<SessionViewModel>().user?.id,
  )..load();

  /// The business part appears once there is a store.
  bool get _hasBusiness => _dashboard.stores?.isNotEmpty ?? false;
  bool _hadBusiness = false;

  @override
  void initState() {
    super.initState();
    _dashboard.addListener(_businessChanged);
    _personal.addListener(_remindersChanged);
    _debts.addListener(_remindersChanged);
  }

  Timer? _reminderTimer;

  /// Regular payments or debts changed: plan the phone's reminders again
  /// (once things settle).
  void _remindersChanged() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer(const Duration(seconds: 1), _syncReminders);
  }

  void _syncReminders() {
    if (!mounted || !_personal.hasData) return;
    final l10n = context.l10n;
    final planner = ReminderPlanner(
      title: l10n.remTitle,
      paymentTomorrow: l10n.remPaymentTomorrow,
      paymentToday: l10n.remPaymentToday,
      debtTomorrow: l10n.remDebtTomorrow,
      debtToday: l10n.remDebtToday,
      money: context.money,
    );
    context.read<ReminderService>().replaceAll(
      planner.plan(
        recurring: _personal.recurring,
        debts: [..._debts.owedToMe, ..._debts.iOwe, ..._debts.loans],
        now: DateTime.now(),
      ),
    );
  }

  void _businessChanged() {
    if (_hasBusiness != _hadBusiness && mounted) {
      setState(() => _hadBusiness = _hasBusiness);
    }
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _personal.removeListener(_remindersChanged);
    _debts.removeListener(_remindersChanged);
    _dashboard.removeListener(_businessChanged);
    _dashboard.dispose();
    _personal.dispose();
    _salesVm?.dispose();
    _payrollVm?.dispose();
    _historyVm?.dispose();
    _debts.dispose();
    _notifications.dispose();
    super.dispose();
  }

  /// After something was added from the "+" sheet: the tabs show it.
  void _refreshAll() {
    _dashboard.load();
    _salesVm?.load();
    _payrollVm?.load();
    _historyVm?.load();
    _notifications.load();
  }

  /// The sales list: its own page, from "+", home or a notification.
  Future<void> _openSales() async {
    _sales.load();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _sales,
          child: const SalesView(),
        ),
      ),
    );
    _refreshAll();
  }

  /// The history: its own page, from "+" or home's app bar.
  Future<void> _openHistory() async {
    final history = _history;
    history.load();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: history,
          child: const HistoryView(),
        ),
      ),
    );
    _refreshAll();
  }

  /// Salaries: their own page, opened from "+" or a notification.
  Future<void> _openPayroll() async {
    await _payroll.load();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: _payroll,
          child: const PayrollView(),
        ),
      ),
    );
    _refreshAll();
  }

  /// The shop's dashboard (the former home), as a page.
  Future<void> _openBusiness() async {
    final l10n = context.l10n;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _dashboard),
            ChangeNotifierProvider.value(value: _notifications),
          ],
          child: HomeView(
            title: l10n.phMyBusiness,
            onOpenSales: _openSales,
            onOpenLink: _openLink,
            onOpenHistory: _openHistory,
          ),
        ),
      ),
    );
    _refreshAll();
  }

  Future<void> _openNotifications() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider.value(
        value: _notifications,
        child: NotificationsView(onOpenLink: _openLink),
      ),
    ),
  );

  /// A personal expense / income / transfer, or the regular payments.
  Future<void> _openPersonal(Widget page) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          ChangeNotifierProvider.value(value: _personal, child: page),
    ),
  );

  /// A notification was tapped: its screen.
  void _openLink(NotificationLink link) {
    switch (link) {
      case NotificationLink.sales:
        _openSales();
      case NotificationLink.payroll:
        _openPayroll();
      case NotificationLink.stores:
        _open(const StoresView());
      case NotificationLink.unknown:
        break;
    }
  }

  Future<void> _open(Widget screen) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (saved ?? false) _refreshAll();
  }

  void _quickActions() {
    final l10n = context.l10n;
    final p = context.palette;
    final business = _hasBusiness;
    final actions = [
      (
        Icons.mic_rounded,
        l10n.qeTitle,
        p.primary,
        p.primaryLight,
        () => _openPersonal(const QuickEntryView()),
      ),
      (
        Icons.north_east_rounded,
        l10n.pfExpense,
        p.error,
        p.errorLight,
        () => _openPersonal(const MoneyTransactionFormView()),
      ),
      (
        Icons.south_west_rounded,
        l10n.pfIncome,
        p.success,
        p.successLight,
        () => _openPersonal(
          const MoneyTransactionFormView(kind: MoneyTransactionKind.income),
        ),
      ),
      (
        Icons.swap_horiz_rounded,
        l10n.pfTransfer,
        p.primary,
        p.primaryLight,
        () => _openPersonal(
          const MoneyTransactionFormView(kind: MoneyTransactionKind.transfer),
        ),
      ),
      (
        Icons.event_repeat_rounded,
        l10n.pfRecurring,
        p.warning,
        p.warningLight,
        () => _openPersonal(const RecurringPaymentsView()),
      ),
      if (business) ...[
        (
          Icons.point_of_sale_rounded,
          l10n.actionNewSale,
          p.success,
          p.successLight,
          () => _open(const SaleFormView()),
        ),
        (
          Icons.receipt_outlined,
          l10n.actionSalesList,
          p.success,
          p.successLight,
          _openSales,
        ),
        (
          Icons.receipt_long_outlined,
          l10n.actionStoreExpense,
          p.error,
          p.errorLight,
          () => _open(const ExpenseFormView()),
        ),
        (
          Icons.payments_outlined,
          l10n.navPayroll,
          p.primary,
          p.primaryLight,
          _openPayroll,
        ),
        (
          Icons.person_add_alt_1_outlined,
          l10n.actionNewEmployee,
          p.primary,
          p.primaryLight,
          () => _open(const EmployeeFormView()),
        ),
      ],
      // A store starts the business part.
      (
        Icons.storefront_outlined,
        l10n.actionNewStore,
        p.warning,
        p.warningLight,
        () => _open(const StoreFormView()),
      ),
    ];
    showAppBottomSheet<void>(
      context,
      title: l10n.quickActionsTitle,
      builder: (sheet) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        child: Column(
          children: [
            for (var start = 0; start < actions.length; start += 2) ...[
              if (start > 0) const SizedBox(height: AppSpacing.md),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = start; i < start + 2; i++) ...[
                      if (i > start) const SizedBox(width: AppSpacing.md),
                      // An odd last action keeps its half width.
                      if (i >= actions.length)
                        const Expanded(child: SizedBox())
                      else
                        Expanded(
                          child: QuickActionCell(
                            icon: actions[i].$1,
                            label: actions[i].$2,
                            color: actions[i].$3,
                            background: actions[i].$4,
                            onTap: () {
                              Navigator.of(sheet).pop();
                              actions[i].$5();
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final items = [
      (
        Icons.space_dashboard_outlined,
        Icons.space_dashboard_rounded,
        l10n.navHome,
      ),
      (
        Icons.receipt_long_outlined,
        Icons.receipt_long_rounded,
        l10n.navOperations,
      ),
      (
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded,
        l10n.navDebts,
      ),
      (Icons.grid_view_outlined, Icons.grid_view_rounded, l10n.navMore),
    ];
    Widget tab(int index) => BottomNavItem(
      icon: items[index].$1,
      selectedIcon: items[index].$2,
      label: items[index].$3,
      selected: _index == index,
      onTap: () => setState(() => _index = index),
    );
    return Scaffold(
      // The AI assistant, always in the bottom-right corner on every tab.
      floatingActionButton: AssistantFab(
        tooltip: l10n.assistantTitle,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ChatView(personalContext: _personal.summary),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: IndexedStack(
        index: _index,
        children: [
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _personal),
              ChangeNotifierProvider.value(value: _dashboard),
              ChangeNotifierProvider.value(value: _notifications),
            ],
            child: PersonalHomeView(
              hasBusiness: _hasBusiness,
              onOpenBusiness: _openBusiness,
              onAddStore: () => _open(const StoreFormView()),
              onOpenNotifications: _openNotifications,
            ),
          ),
          ChangeNotifierProvider.value(
            value: _personal,
            child: const MoneyTransactionsView(),
          ),
          ChangeNotifierProvider.value(value: _debts, child: const DebtsView()),
          ChangeNotifierProvider.value(
            value: _personal,
            child: MoreView(
              onChanged: _refreshAll,
              onOpenHistory: _openHistory,
              hasBusiness: _hasBusiness,
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                tab(0),
                tab(1),
                Expanded(
                  child: Center(
                    child: AddNavButton(
                      tooltip: l10n.navAdd,
                      onPressed: _quickActions,
                    ),
                  ),
                ),
                tab(2),
                tab(3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
