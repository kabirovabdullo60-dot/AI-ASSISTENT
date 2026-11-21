import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../models/payment_model.dart';
import '../services/payroll_service.dart';
import '../viewmodels/employee_payroll_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/app_feedback.dart';
import '../widgets/async_state_view.dart';
import '../widgets/figure_card.dart';
import '../widgets/payroll_status_badge.dart';
import '../widgets/record_tile.dart';
import '../widgets/section_header.dart';

/// One employee's salary (`GET /api/payroll/employee/{id}`): totals, the
/// months and the payments; a payment can be cancelled.
class EmployeePayrollView extends StatelessWidget {
  const EmployeePayrollView({required this.employeeId, super.key});

  final String employeeId;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        EmployeePayrollViewModel(context.read<PayrollService>(), employeeId)
          ..load(),
    child: const _EmployeePayroll(),
  );
}

class _EmployeePayroll extends StatelessWidget {
  const _EmployeePayroll();

  Future<void> _cancel(BuildContext context, PaymentModel payment) async {
    final l10n = context.l10n;
    final vm = context.read<EmployeePayrollViewModel>();
    final feedback = AppSnackbar.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.paymentCancelTitle,
      message: l10n.paymentCancelMessage(context.money(payment.amount)),
      confirmLabel: l10n.paymentCancel,
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await vm.cancelPayment(payment.id);
      feedback.showSuccess(l10n.paymentCancelled);
    } on ApiException catch (e) {
      feedback.showError(errorText(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<EmployeePayrollViewModel>();
    final data = vm.data;
    return Scaffold(
      appBar: AppBar(
        title: Text(data?.employee.fullName ?? l10n.payrollHistory),
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
              AppSpacing.xxxl,
            ),
            children: [
              Text(
                '${data!.employee.position} · ${data.employee.storeName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: FigureCard(
                      label: l10n.payrollDueTotal,
                      value: context.money(data.totalDue),
                      caption: l10n.payrollMonthsWorked(data.monthsWorked),
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
                caption: l10n.payrollMonthlySalary(
                  context.money(data.monthlySalary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.payrollMonths),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    for (final m in data.months.reversed)
                      RecordTile(
                        icon: Icons.calendar_month_outlined,
                        iconColor: p.primary,
                        iconBackground: p.primaryLight,
                        title: context.monthYear(m.month, m.year),
                        subtitle: l10n.payrollPaidOf(
                          context.money(m.paidAmount),
                          context.money(m.dueAmount),
                        ),
                        badge: PayrollStatusBadge(status: m.status),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.payrollPayments),
              if (data.payments.isEmpty)
                AppCard(
                  child: Text(
                    l10n.payrollNoPayments,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      for (final payment in data.payments)
                        RecordTile(
                          icon: Icons.payments_outlined,
                          iconColor: p.success,
                          iconBackground: p.successLight,
                          title: context.money(payment.amount),
                          subtitle: [
                            context.formatDate(payment.paymentDate),
                            l10n.paymentFor(
                              context.monthYear(payment.month, payment.year),
                            ),
                            if (payment.note != null) payment.note!,
                          ].join(' · '),
                          badge: TextButton(
                            onPressed: () => _cancel(context, payment),
                            child: Text(l10n.paymentCancel),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
