import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/sales_report_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/sales_period.dart';
import '../widgets/app_card.dart';
import '../widgets/async_state_view.dart';
import '../widgets/figure_card.dart';
import '../widgets/period_chips.dart';
import '../widgets/section_header.dart';
import '../widgets/share_bar_row.dart';
import '../widgets/stat_tile.dart';
import '../widgets/summary_card.dart';

/// Home (OFAR layout): month sales card, today, period figures with the
/// change, salaries of the month, stores and employees, top stores.
class HomeView extends StatelessWidget {
  const HomeView({required this.onOpenSales, super.key});

  final VoidCallback onOpenSales;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<DashboardViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navHome)),
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
          title: l10n.homeMonthSales,
          value: context.money(d.monthSales),
          parts: [
            (l10n.homeToday, context.money(d.todaySales)),
            (l10n.homeWeek, context.money(d.weekSales)),
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
