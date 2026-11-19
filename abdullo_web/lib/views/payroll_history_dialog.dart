import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/payment_model.dart';
import '../models/payroll_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../widgets/status_badge.dart';
import '../core/motion/app_dialog.dart';

/// All months and payments of one employee — GET /api/payroll/employee/{id}.
/// A payment can be cancelled here (DELETE /api/payroll/{id}).
class PayrollHistoryDialog extends StatefulWidget {
  const PayrollHistoryDialog({super.key, required this.payroll});

  final PayrollModel payroll;

  static Future<void> show(BuildContext context, PayrollModel payroll) => showAppDialog<void>(
    context: context,
    builder: (_) => PayrollHistoryDialog(payroll: payroll),
  );

  @override
  State<PayrollHistoryDialog> createState() => _PayrollHistoryDialogState();
}

class _PayrollHistoryDialogState extends State<PayrollHistoryDialog> {
  late Future<EmployeePayrollModel> _future = _load();

  Future<EmployeePayrollModel> _load() => context.read<PayrollViewModel>().history(widget.payroll.employeeId);

  Future<void> _cancel(PaymentModel p) async {
    final tr = context.l10n;
    final ok = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.cancelPaymentTitle),
        content: Text('${formatAmount(p.amount)} TJS · ${formatDate(p.paymentDate)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr.close)),
          FilledButton(
            key: const Key('confirm-cancel-payment'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.cancelPayment),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final dashboard = context.read<DashboardViewModel>();
    final error = await context.read<PayrollViewModel>().cancelPayment(p.id);
    if (!mounted) return;
    if (error == null) {
      dashboard.load();
      setState(() {
        _future = _load();
      });
    }
    showResult(context, error, success: tr.paymentCancelled);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return AlertDialog(
      title: Text(tr.paymentsOf(widget.payroll.employeeName)),
      content: SizedBox(
        width: 480,
        child: FutureBuilder<EmployeePayrollModel>(
          future: _future,
          builder: (context, snap) {
            if (snap.hasError) return Text(tr.loadError);
            if (!snap.hasData) {
              return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
            }
            final h = snap.data!;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr.salarySummary(
                      '${formatAmount(h.totalDue)} TJS',
                      '${formatAmount(h.totalPaid)} TJS',
                      '${formatAmount(h.totalRemaining)} TJS',
                    ),
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 12),
                  Text(tr.payments, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (h.payments.isEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(tr.noPaymentsYet)),
                  for (final p in h.payments)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.account_balance_outlined, color: AppColors.green),
                      title: Text(
                        '+${formatAmount(p.amount)} TJS',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${formatMonthYear(DateTime(p.year, p.month))} · ${formatDate(p.paymentDate)}'
                        '${(p.note ?? '').isEmpty ? '' : ' · ${p.note}'}',
                      ),
                      trailing: IconButton(
                        key: Key('cancel-payment-${p.id}'),
                        tooltip: tr.cancelPayment,
                        icon: Icon(Icons.undo, color: AppColors.red),
                        onPressed: () => _cancel(p),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(tr.months, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  for (final m in h.months.reversed.take(12))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(formatMonthYear(DateTime(m.year, m.month)))),
                          Text('${formatAmount(m.paid)} / ${formatAmount(m.due)}'),
                          const SizedBox(width: 8),
                          StatusBadge(
                            tr.payStatus(m.status),
                            tone: switch (m.status) {
                              PayStatus.paid => BadgeTone.positive,
                              PayStatus.partial => BadgeTone.warning,
                              PayStatus.unpaid => BadgeTone.negative,
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.close))],
    );
  }
}
