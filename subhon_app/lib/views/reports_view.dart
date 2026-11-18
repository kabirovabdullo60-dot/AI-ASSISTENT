import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../services/reports_service.dart';
import '../viewmodels/reports_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/async_state_view.dart';
import '../widgets/figure_card.dart';
import '../widgets/period_switcher.dart';
import '../widgets/record_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/share_bar_row.dart';

/// Reports: stores compared this month
/// (`/api/reports/store-comparison`), payroll of a year
/// (`/api/reports/payroll`) and employees (`/api/reports/employees`).
class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        ReportsViewModel(context.read<ReportsService>())..load(),
    child: const _Reports(),
  );
}

class _Reports extends StatelessWidget {
  const _Reports();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<ReportsViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: AsyncStateView(
          isLoading: vm.isLoading,
          error: vm.error,
          hasData: vm.hasData,
          onRetry: vm.load,
          builder: (context) {
            final stores = vm.stores!;
            final rows = [...stores.stores]
              ..sort((a, b) => a.rank.compareTo(b.rank));
            final payroll = vm.payroll;
            final employees = vm.employees;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xxxl,
              ),
              children: [
                SectionHeader(title: l10n.reportStores),
                FigureCard(
                  label: l10n.reportStoresPeriod(
                    context.formatShortDate(stores.period.startDate),
                    context.formatShortDate(stores.period.endDate),
                  ),
                  value: context.money(stores.totalAmount),
                  valueColor: p.success,
                  caption: l10n.salesCount(stores.salesCount),
                ),
                const SizedBox(height: AppSpacing.md),
                if (rows.isEmpty)
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
                        for (final (i, s) in rows.indexed) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.md),
                          ShareBarRow(
                            icon: Icons.storefront_outlined,
                            label: '${s.rank}. ${s.storeName}',
                            value: context.money(s.totalAmount),
                            share: s.sharePercent / 100,
                            shareText: context.percent(s.sharePercent),
                          ),
                          if (s.changePercent != null)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l10n.homeChange(
                                  context.percent(
                                    s.changePercent!,
                                    signed: true,
                                  ),
                                  l10n.compareMonth,
                                ),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: s.changePercent! >= 0
                                          ? p.success
                                          : p.error,
                                    ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(title: l10n.reportPayroll),
                PeriodSwitcher(
                  label: '${vm.year}',
                  previousTooltip: l10n.periodPrevious,
                  nextTooltip: l10n.periodNext,
                  onPrevious: () => vm.shiftYear(-1),
                  onNext: () => vm.shiftYear(1),
                ),
                const SizedBox(height: AppSpacing.md),
                if (payroll == null)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FigureCard(
                          label: l10n.payrollDue,
                          value: context.money(payroll.totalDue),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FigureCard(
                          label: l10n.payrollPaidAmount,
                          value: context.money(payroll.totalPaid),
                          valueColor: p.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        for (final m in payroll.months)
                          RecordTile(
                            icon: Icons.calendar_month_outlined,
                            iconColor: p.primary,
                            iconBackground: p.primaryLight,
                            title: context.monthYear(m.month, payroll.year),
                            subtitle: l10n.payrollPaidOf(
                              context.money(m.paidAmount),
                              context.money(m.dueAmount),
                            ),
                            value: context.money(m.remainingAmount),
                            valueColor: m.remainingAmount > 0 ? p.error : null,
                          ),
                      ],
                    ),
                  ),
                ],
                if (employees != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: l10n.reportEmployees),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        for (final s in employees.byStore)
                          RecordTile(
                            icon: Icons.storefront_outlined,
                            iconColor: p.primary,
                            iconBackground: p.primaryLight,
                            title: s.storeName,
                            subtitle: l10n.reportEmployeesCount(
                              s.activeEmployees,
                              s.employeesCount,
                            ),
                            value: context.money(s.monthlySalaryTotal),
                          ),
                        for (final pos in employees.byPosition)
                          RecordTile(
                            icon: Icons.work_outline_rounded,
                            iconColor: p.warning,
                            iconBackground: p.warningLight,
                            title: pos.position,
                            subtitle: l10n.reportEmployeesCount(
                              pos.activeEmployees,
                              pos.employeesCount,
                            ),
                            value: context.money(pos.monthlySalaryTotal),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
