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
import '../services/target_service.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/notifications_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../viewmodels/sales_view_model.dart';
import '../widgets/add_nav_button.dart';
import '../widgets/app_feedback.dart';
import '../widgets/bottom_nav_item.dart';
import '../widgets/quick_action_cell.dart';
import 'employee_form_view.dart';
import 'home_view.dart';
import 'more_view.dart';
import 'payroll_view.dart';
import 'sale_form_view.dart';
import 'sales_view.dart';
import 'store_form_view.dart';
import 'stores_view.dart';

/// The app after login, with OFAR's bottom navigation:
/// Главная · Продажи · [+] · Зарплаты · Ещё.
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
    context.read<TargetService>(),
    context.read<ActivityService>(),
  )..load();
  late final _sales = SalesViewModel(
    context.read<SalesService>(),
    context.read<StoreService>(),
  )..load();
  late final _payroll = PayrollViewModel(context.read<PayrollService>())
    ..load();
  late final _notifications = NotificationsViewModel(
    context.read<NotificationService>(),
  )..load();

  @override
  void dispose() {
    _dashboard.dispose();
    _sales.dispose();
    _payroll.dispose();
    _notifications.dispose();
    super.dispose();
  }

  /// After something was added from the "+" sheet: the tabs show it.
  void _refreshAll() {
    _dashboard.load();
    _sales.load();
    _payroll.load();
    _notifications.load();
  }

  /// A notification was tapped: its screen.
  void _openLink(NotificationLink link) {
    switch (link) {
      case NotificationLink.sales:
        setState(() => _index = 1);
      case NotificationLink.payroll:
        setState(() => _index = 2);
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
        Icons.payments_outlined,
        l10n.actionPaySalary,
        p.primary,
        p.primaryLight,
        () => setState(() => _index = 2),
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
      (Icons.payments_outlined, Icons.payments_rounded, l10n.navPayroll),
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
          ChangeNotifierProvider.value(
            value: _payroll,
            child: const PayrollView(),
          ),
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
