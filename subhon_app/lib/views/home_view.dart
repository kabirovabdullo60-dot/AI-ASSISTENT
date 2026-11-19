import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/payment_method_text.dart';
import '../models/sales_report_model.dart';
import '../models/notification_link.dart';
import '../models/payment_method.dart';
import '../models/target_period.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/notifications_view_model.dart';
import '../viewmodels/sales_period.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_card.dart';
import '../widgets/async_state_view.dart';
import '../widgets/figure_card.dart';
import '../widgets/notification_bell.dart';
import '../widgets/period_chips.dart';
import '../widgets/section_header.dart';
import '../widgets/share_bar_row.dart';
import '../widgets/stat_tile.dart';
import '../widgets/summary_card.dart';
import '../widgets/sales_target_card.dart';
import 'activity_view.dart';
import 'chat_view.dart';
import 'notifications_view.dart';

/// Home (OFAR layout): month sales card, today, period figures with the
/// change, this month's profit and the sales targets, salaries of the
/// month, stores and employees, top stores.
class HomeView extends StatelessWidget {
  const HomeView({
    required this.onOpenSales,
    required this.onOpenLink,
    super.key,
  });

  final VoidCallback onOpenSales;

  /// A notification was tapped: open its screen.
  final ValueChanged<NotificationLink> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<DashboardViewModel>();
    final notifications = context.watch<NotificationsViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHome),
        actions: [
          IconButton(
            tooltip: l10n.assistantTitle,
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const ChatView())),
            icon: const Icon(Icons.auto_awesome_outlined),
          ),
          NotificationBell(
            unread: notifications.unreadCount,
            tooltip: l10n.notificationsTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ChangeNotifierProvider.value(
                  value: notifications,
                  child: NotificationsView(onOpenLink: onOpenLink),
                ),
              ),
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
          builder: (context) => _Body(vm: vm, onOpenSales: onOpenSales),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.vm, required this.onOpenSales});

  final DashboardViewModel vm;
  final VoidCallback onOpenSales;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final d = vm.dashboard!;
    const gap = SizedBox(height: AppSpacing.md);
    final top = [...?vm.topStores?.stores]
      ..sort((a, b) => a.rank.compareTo(b.rank));
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.xxxl,
      ),
      children: [
        SummaryCard(
          title: l10n.homeTodaySales,
          value: context.money(d.todaySales),
          parts: [
            (l10n.homeWeek, context.money(d.weekSales)),
            (l10n.homeMonth, context.money(d.monthSales)),
          ],
        ),
        gap,
        StatTile(
          icon: Icons.point_of_sale_rounded,
          label: l10n.homeRevenueToday,
          value: context.money(d.todaySales),
          caption: l10n.salesCount(d.todaySalesCount),
          onTap: onOpenSales,
        ),
        const SizedBox(height: AppSpacing.xl),
        PeriodChips<SalesPeriod>(
          values: SalesPeriod.values,
          selected: vm.period,
          onSelected: vm.selectPeriod,
          label: (period) => switch (period) {
            SalesPeriod.today => l10n.periodToday,
            SalesPeriod.week => l10n.periodWeek,
            SalesPeriod.month => l10n.periodMonth,
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (vm.periodReport case final report?)
          AnimatedOpacity(
            opacity: vm.isPeriodLoading ? 0.5 : 1,
            duration: const Duration(milliseconds: 150),
            child: _PeriodFigures(report: report, period: vm.period),
          ),
        if (vm.periodReport?.byPaymentMethod.where((m) => m.totalAmount > 0)
            case final methods? when methods.isNotEmpty) ...[
          gap,
          Text(
            l10n.homeByPayment,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              children: [
                for (final (i, m) in methods.indexed) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  ShareBarRow(
                    icon: switch (m.paymentMethod) {
                      PaymentMethod.cash => Icons.payments_outlined,
                      PaymentMethod.card => Icons.credit_card_rounded,
                      PaymentMethod.qr => Icons.qr_code_2_rounded,
                      PaymentMethod.mixed => Icons.call_split_rounded,
                      null => Icons.help_outline_rounded,
                    },
                    label: paymentMethodText(l10n, m.paymentMethod),
                    value: context.money(m.totalAmount),
                    share: m.sharePercent / 100,
                    shareText: context.percent(m.sharePercent),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: l10n.homeTargetsProfit),
        FigureCard(
          label: l10n.homeMonthProfit,
          value: context.money(d.monthProfit, signed: true),
          valueColor: d.monthProfit >= 0 ? p.success : p.error,
          caption: l10n.homeProfitCaption(
            context.money(d.monthExpenses),
            d.monthMarginPercent == null
                ? l10n.profitNoSales
                : l10n.profitMargin(context.percent(d.monthMarginPercent!)),
          ),
        ),
        gap,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SalesTargetCard(
                  period: TargetPeriod.week,
                  sales: d.weekSales,
                  target: d.weekTarget,
                  hint: l10n.targetSheetHint,
                  onSave: (amount) => vm.setTarget(TargetPeriod.week, amount),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SalesTargetCard(
                  period: TargetPeriod.month,
                  sales: d.monthSales,
                  target: d.monthTarget,
                  hint: l10n.targetSheetHint,
                  onSave: (amount) => vm.setTarget(TargetPeriod.month, amount),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: l10n.homeSalaries),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FigureCard(
                label: l10n.payrollDue,
                value: context.money(d.salaryDueThisMonth),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FigureCard(
                label: l10n.payrollPaidAmount,
                value: context.money(d.paidSalaryThisMonth),
                valueColor: p.success,
              ),
            ),
          ],
        ),
        gap,
        FigureCard(
          label: l10n.payrollRemaining,
          value: context.money(d.remainingSalaryThisMonth),
          valueColor: d.remainingSalaryThisMonth > 0 ? p.error : null,
          caption: l10n.homeRemainingTotal(
            context.money(d.remainingSalaryTotal),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: l10n.homeBusiness),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FigureCard(
                label: l10n.navStores,
                value: '${d.activeStores}',
                caption: l10n.homeOfTotal(d.totalStores),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FigureCard(
                label: l10n.navEmployees,
                value: '${d.activeEmployees}',
                caption: l10n.homeOfTotal(d.totalEmployees),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: l10n.homeTopStores,
          actionLabel: l10n.homeShowAll,
          onAction: onOpenSales,
        ),
        if (top.isEmpty)
          AppCard(
            child: Text(
              l10n.homeNoSales,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (final (i, s) in top.take(5).indexed) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  ShareBarRow(
                    icon: Icons.storefront_outlined,
                    label: s.storeName,
                    value: context.money(s.totalAmount),
                    share: s.sharePercent / 100,
                    shareText: context.percent(s.sharePercent),
                  ),
                ],
              ],
            ),
          ),
        if (vm.recentActivity case final recent? when recent.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: l10n.activityTitle,
            actionLabel: l10n.homeShowAll,
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ActivityView()),
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [for (final a in recent) ActivityTile(activity: a)],
            ),
          ),
        ],
      ],
    );
  }
}

/// Sales of the chosen period and the average sale, with the change
/// against the previous period of the same length.
class _PeriodFigures extends StatelessWidget {
  const _PeriodFigures({required this.report, required this.period});

  final SalesReportModel report;
  final SalesPeriod period;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final change = report.changePercent;
    final compare = switch (period) {
      SalesPeriod.today => l10n.compareToday,
      SalesPeriod.week => l10n.compareWeek,
      SalesPeriod.month => l10n.compareMonth,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FigureCard(
            label: l10n.homePeriodSales,
            value: context.money(report.totalAmount),
            valueColor: p.success,
            caption: change == null
                ? l10n.homeNoComparison
                : l10n.homeChange(
                    context.percent(change, signed: true),
                    compare,
                  ),
            captionColor: change == null || change == 0
                ? null
                : change > 0
                ? p.success
                : p.error,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FigureCard(
            label: l10n.homeAverageSale,
            value: context.money(report.averageSaleAmount),
            caption: l10n.salesCount(report.salesCount),
          ),
        ),
      ],
    );
  }
}
