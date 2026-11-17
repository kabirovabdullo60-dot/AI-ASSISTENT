import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final history = context.watch<PayrollViewModel>().historyFor(payroll.id);
    return AlertDialog(
      title: Text('${payroll.employeeName} — payments'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Salary ${formatAmount(payroll.salary)} TJS · paid ${formatAmount(payroll.disbursed)} TJS',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              const Text('Paid before the records in this app (no separate payments listed).')
            else
              for (final d in history)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_outlined, color: AppColors.green),
                  title: Text('+${formatAmount(d.amount)} TJS', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${d.method} • ${d.reference}${d.part.isEmpty ? '' : ' • ${d.part}'}'),
                  trailing: Text(
                    '${formatRelativeDay(d.time)}\n${formatTime(d.time)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    );
  }
}
