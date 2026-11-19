import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/money_text.dart';
import '../models/money_account_model.dart';
import '../models/money_transaction_kind.dart';
import '../models/money_transaction_model.dart';

/// One personal operation as a rounded card: the category (or "Перевод"),
/// the account (and the note), the amount (+ green for income).
class MoneyTransactionTile extends StatelessWidget {
  const MoneyTransactionTile({
    required this.transaction,
    required this.account,
    required this.onTap,
    this.toAccount,
    super.key,
  });

  final MoneyTransactionModel transaction;
  final MoneyAccountModel? account;
  final MoneyAccountModel? toAccount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final t = transaction;
    final (icon, color, title) = switch (t.kind) {
      MoneyTransactionKind.transfer => (
        Icons.swap_horiz_rounded,
        p.primary,
        l10n.pfTransfer,
      ),
      _ when t.category != null => (
        moneyCategoryIcon(t.category!),
        t.kind == MoneyTransactionKind.income ? p.success : p.error,
        moneyCategoryText(l10n, t.category!),
      ),
      MoneyTransactionKind.income => (
        Icons.south_west_rounded,
        p.success,
        l10n.pfIncome,
      ),
      MoneyTransactionKind.expense => (
        Icons.north_east_rounded,
        p.error,
        l10n.pfExpense,
      ),
    };
    final where = t.kind == MoneyTransactionKind.transfer
        ? '${account?.name ?? '?'} → ${toAccount?.name ?? '?'}'
        : account?.name ?? '';
    final subtitle = [where, ?t.note].where((s) => s.isNotEmpty).join(' · ');
    return Material(
      color: p.surface,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                t.kind == MoneyTransactionKind.transfer
                    ? context.money(t.amount)
                    : context.money(t.signed, signed: true),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: switch (t.kind) {
                    MoneyTransactionKind.income => p.success,
                    MoneyTransactionKind.expense => p.textPrimary,
                    MoneyTransactionKind.transfer => p.textSecondary,
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
