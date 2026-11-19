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
import '../viewmodels/activity_view_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/notifications_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../viewmodels/sales_view_model.dart';
import '../widgets/add_nav_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/assistant_fab.dart';
import '../widgets/bottom_nav_item.dart';
import '../widgets/quick_action_cell.dart';
import 'activity_view.dart';
import 'chat_view.dart';
import 'employee_form_view.dart';
import 'expense_form_view.dart';
import 'home_view.dart';
import 'more_view.dart';
import 'payroll_view.dart';
import 'sale_form_view.dart';
import 'sales_view.dart';
import 'store_form_view.dart';
import 'stores_view.dart';

/// The app after login, with OFAR's bottom navigation:
/// Главная · Продажи · [+] · История · Ещё. Salaries open from "+".
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
  late final _sales = SalesViewModel(
    context.read<SalesService>(),
    context.read<StoreService>(),
  )..load();
  /// Created the first time salaries are opened (they are no longer a tab).
  PayrollViewModel? _payrollVm;
  PayrollViewModel get _payroll =>
      _payrollVm ??= PayrollViewModel(context.read<PayrollService>());
  late final _history = ActivityViewModel(context.read<ActivityService>())
    ..load();
  late final _notifications = NotificationsViewModel(
    context.read<NotificationService>(),
  )..load();

  @override
  void dispose() {
    _dashboard.dispose();
    _sales.dispose();
    _payrollVm?.dispose();
    _history.dispose();
    _notifications.dispose();
    super.dispose();
  }

  /// After something was added from the "+" sheet: the tabs show it.
  void _refreshAll() {
    _dashboard.load();
    _sales.load();
    _payrollVm?.load();
    _history.load();
    _notifications.load();
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

  /// A notification was tapped: its screen.
  void _openLink(NotificationLink link) {
    switch (link) {
      case NotificationLink.sales:
        setState(() => _index = 1);
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
    final actions = [
      (
        Icons.point_of_sale_rounded,
        l10n.actionNewSale,
        p.success,
        p.successLight,
        () => _open(const SaleFormView()),
      ),
      (
        Icons.receipt_long_outlined,
        l10n.actionNewExpense,
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
        Icons.storefront_outlined,
        l10n.actionNewStore,
        p.warning,
        p.warningLight,
        () => _open(const StoreFormView()),
      ),
      (
        Icons.person_add_alt_1_outlined,
        l10n.actionNewEmployee,
        p.primary,
        p.primaryLight,
        () => _open(const EmployeeFormView()),
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
        Icons.point_of_sale_outlined,
        Icons.point_of_sale_rounded,
        l10n.navSales,
      ),
      (Icons.history_rounded, Icons.history_rounded, l10n.activityHistory),
      (Icons.grid_view_outlined, Icons.grid_view_rounded, l10n.navMore),
    ];
    Widget tab(int index) => BottomNavItem(
      icon: items[index].$1,
      selectedIcon: items[index].$2,
      label: items[index].$3,
      selected: _index == index,
      onTap: () {
        // The history is always fresh when opened.
        if (index == 2 && _index != 2) _history.load();
        setState(() => _index = index);
      },
    );
    return Scaffold(
      // The AI assistant, always in the bottom-right corner on every tab.
      floatingActionButton: AssistantFab(
        tooltip: l10n.assistantTitle,
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ChatView())),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: IndexedStack(
        index: _index,
        children: [
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _dashboard),
              ChangeNotifierProvider.value(value: _notifications),
            ],
            child: HomeView(
              onOpenSales: () => setState(() => _index = 1),
              onOpenLink: _openLink,
            ),
          ),
          ChangeNotifierProvider.value(value: _sales, child: const SalesView()),
          ActivityView(viewModel: _history, title: l10n.activityHistory),
          MoreView(onChanged: _refreshAll),
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
