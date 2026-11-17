import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/payroll_model.dart';
import '../viewmodels/payroll_view_model.dart';

/// Payments made to one employee in the selected month.
class PayrollHistoryDialog extends StatelessWidget {
  const PayrollHistoryDialog({super.key, required this.payroll});

  final PayrollModel payroll;

  static Future<void> show(BuildContext context, PayrollModel payroll) => showDialog<void>(
    context: context,
    builder: (_) => PayrollHistoryDialog(payroll: payroll),
  );

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final history = context.watch<PayrollViewModel>().historyFor(payroll.id);
    return AlertDialog(
      title: Text(tr.paymentsOf(payroll.employeeName)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.salarySummary(
                '${formatAmount(payroll.salary)} TJS',
                '${formatAmount(payroll.disbursed)} TJS',
                '${formatAmount(payroll.remaining)} TJS',
              ),
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              Text(tr.paidBeforeRecords)
            else
              for (final d in history)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_outlined, color: AppColors.green),
                  title: Text('+${formatAmount(d.amount)} TJS', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${tr.paymentMethod(d.method)} • ${d.reference}${d.part.isEmpty ? '' : ' • ${d.part}'}',
                  ),
                  trailing: Text(
                    '${formatRelativeDay(d.time)}\n${formatTime(d.time)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.close))],
    );
  }
}
