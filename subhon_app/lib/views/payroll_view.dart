import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/monthly_payroll_row_model.dart';
import '../models/payroll_status.dart';
import '../viewmodels/payroll_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/async_state_view.dart';
import '../widgets/figure_card.dart';
import '../widgets/payroll_status_badge.dart';
import '../widgets/period_switcher.dart';
import '../widgets/record_tile.dart';
import 'payment_form_view.dart';

/// Salaries of a month (`GET /api/payroll/monthly`): totals and every
/// employee with PAID / PARTIAL / UNPAID. Tap a row to pay.
class PayrollView extends StatelessWidget {
  const PayrollView({super.key});

  Future<void> _pay(BuildContext context, MonthlyPayrollRowModel row) async {
    final vm = context.read<PayrollViewModel>();
    final paid = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            PaymentFormView(row: row, month: vm.month, year: vm.year),
      ),
    );
    if (paid ?? false) await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<PayrollViewModel>();
    final data = vm.data;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navPayroll)),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xxxl,
          ),
          children: [
            PeriodSwitcher(
              label: context.monthYear(vm.month, vm.year),
              previousTooltip: l10n.periodPrevious,
              nextTooltip: l10n.periodNext,
              onPrevious: vm.isLoading ? null : () => vm.shiftMonth(-1),
              onNext: vm.isLoading ? null : () => vm.shiftMonth(1),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              // The states keep their own centred layout under the switcher.
              height: data == null ? 420 : null,
              child: AsyncStateView(
                isLoading: vm.isLoading,
                error: vm.error,
                hasData: vm.hasData,
                onRetry: vm.load,
                isEmpty: data != null && data.items.isEmpty,
                empty: AppEmptyView(
                  icon: Icons.payments_outlined,
                  title: l10n.payrollEmptyTitle,
                  message: l10n.payrollEmptyMessage,
                ),
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FigureCard(
                            label: l10n.payrollDue,
                            value: context.money(data!.totalDue),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: FigureCard(
                            label: l10n.payrollPaidAmount,
                            value: context.money(data.totalPaid),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FigureCard(
                      label: l10n.payrollRemaining,
                      value: context.money(data.totalRemaining),
                      valueColor: data.totalRemaining > 0 ? p.error : null,
                      caption: l10n.payrollCounts(
                        data.paidCount,
                        data.partialCount,
                        data.unpaidCount,
                      ),
                    ),
                    if (vm.summary case final all?) ...[
                      const SizedBox(height: AppSpacing.md),
                      FigureCard(
                        label: l10n.payrollAllTimeRemaining,
                        value: context.money(all.totalRemaining),
                        valueColor: all.totalRemaining > 0 ? p.error : null,
                        caption: l10n.payrollAllTimeCaption(
                          context.money(all.totalDue),
                          context.money(all.totalPaid),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Column(
                        children: [
                          for (final row in data.items)
                            RecordTile(
                              icon: Icons.person_outline_rounded,
                              iconColor: p.primary,
                              iconBackground: p.primaryLight,
                              title: row.fullName,
                              subtitle: [
                                row.position,
                                row.storeName,
                                if (row.status != PayrollStatus.paid)
                                  l10n.payrollLeft(
                                    context.money(row.remainingAmount),
                                  ),
                              ].join(' · '),
                              value: context.money(row.dueAmount),
                              badge: PayrollStatusBadge(status: row.status),
                              onTap: () => _pay(context, row),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
