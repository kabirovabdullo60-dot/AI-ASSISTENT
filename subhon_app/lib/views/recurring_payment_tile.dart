import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/money_text.dart';
import '../models/recurring_payment_model.dart';
import '../viewmodels/personal_finance_view_model.dart';
import 'recurring_payments_view.dart';

/// One regular payment with its date and "Оплатить" (also used on home).
class RecurringPaymentTile extends StatelessWidget {
  const RecurringPaymentTile({required this.payment, super.key});

  final RecurringPaymentModel payment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<PersonalFinanceViewModel>();
    final overdue = vm.isOverdue(payment);
    final dueToday = payment.nextDate == vm.today;
    return Material(
      color: p.surface,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => RecurringPaymentsView.openForm(context, payment: payment),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: (overdue ? p.error : p.warning).withValues(
                  alpha: 0.12,
                ),
                child: Icon(
                  moneyCategoryIcon(payment.category),
                  color: overdue ? p.error : p.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.name, style: theme.textTheme.titleSmall),
                    Text(
                      overdue
                          ? l10n.pfOverdue(
                              context.formatShortDate(payment.nextDate),
                            )
                          : dueToday
                          ? l10n.pfDueToday
                          : context.formatDate(payment.nextDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: overdue ? p.error : p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.money(payment.amount),
                    style: theme.textTheme.titleSmall,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () =>
                        RecurringPaymentsView.pay(context, payment),
                    child: Text(l10n.pfPay),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
