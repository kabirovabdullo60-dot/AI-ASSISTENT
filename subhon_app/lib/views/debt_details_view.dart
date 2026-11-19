import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/debt_kind.dart';
import '../viewmodels/debts_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_text_field.dart';
import '../widgets/record_tile.dart';
import 'debts_view.dart';

/// One debt or credit: what is left, the progress, its details, the
/// repayments; record a repayment, mark it repaid, edit or delete.
class DebtDetailsView extends StatelessWidget {
  const DebtDetailsView({required this.debtId, super.key});

  final String debtId;

  Future<void> _repay(BuildContext context, DebtsViewModel vm) async {
    final l10n = context.l10n;
    final feedback = AppSnackbar.of(context);
    final amount = await showAppBottomSheet<double>(
      context,
      title: l10n.debtRepay,
      builder: (_) => _RepaySheet(left: vm.byId(debtId)!.remaining),
    );
    if (amount == null) return;
    await vm.repay(debtId, amount);
    feedback.showSuccess(l10n.debtRepaid);
  }

  Future<void> _delete(BuildContext context, DebtsViewModel vm) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.debtDeleteTitle,
      message: l10n.debtDeleteMessage,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    navigator.pop();
    await vm.delete(debtId);
    feedback.showSuccess(l10n.debtDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<DebtsViewModel>();
    final debt = vm.byId(debtId);
    if (debt == null) return const Scaffold();
    final color = switch (debt.kind) {
      DebtKind.owedToMe => p.success,
      DebtKind.iOwe => p.primary,
      _ => p.error,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(debt.name),
        actions: [
          IconButton(
            tooltip: l10n.commonEdit,
            onPressed: () => DebtsView.openForm(context, debt.kind, debt: debt),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: l10n.commonDelete,
            onPressed: () => _delete(context, vm),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(switch (debt.kind) {
                  DebtKind.owedToMe => l10n.debtsOwedToMe,
                  DebtKind.iOwe => l10n.debtsIOwe,
                  DebtKind.credit => l10n.debtCredit,
                  DebtKind.installment => l10n.debtInstallment,
                }, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  debt.isClosed
                      ? l10n.debtClosedBadge
                      : l10n.debtLeft(context.money(debt.remaining)),
                  style: theme.textTheme.headlineSmall?.copyWith(color: color),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(99)),
                  child: LinearProgressIndicator(
                    value: debt.progress,
                    minHeight: 8,
                    backgroundColor: p.surfaceMuted,
                    color: color,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.debtPaidOf(
                    context.money(debt.paid),
                    context.money(debt.amount),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                if (debt.monthlyPayment != null)
                  Text(
                    '${l10n.debtMonthly}: ${context.money(debt.monthlyPayment!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (debt.dueDate != null)
                  Text(
                    debt.isOverdue(vm.today)
                        ? l10n.debtOverdue(context.formatDate(debt.dueDate!))
                        : l10n.debtDue(context.formatDate(debt.dueDate!)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: debt.isOverdue(vm.today) ? p.error : null,
                    ),
                  ),
                if (debt.phone != null)
                  Text(
                    '${l10n.fieldPhone}: ${debt.phone}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (debt.note != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(debt.note!, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          if (!debt.isClosed) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.debtRepay,
              icon: Icons.payments_outlined,
              onPressed: () => _repay(context, vm),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debtRepayAll,
              icon: Icons.check_circle_outline_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: () => vm.close(debtId),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.debtPayments, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: debt.payments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      l10n.debtNoPayments,
                      style: theme.textTheme.bodySmall,
                    ),
                  )
                : Column(
                    children: [
                      for (final payment in debt.payments.reversed)
                        RecordTile(
                          icon: Icons.check_rounded,
                          iconColor: color,
                          iconBackground: color.withValues(alpha: 0.12),
                          title: context.formatDate(payment.date),
                          subtitle: payment.note,
                          value: context.money(payment.amount),
                          valueColor: color,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// How much was repaid (at most what is left); pops the amount.
class _RepaySheet extends StatefulWidget {
  const _RepaySheet({required this.left});

  final double left;

  @override
  State<_RepaySheet> createState() => _RepaySheetState();
}

class _RepaySheetState extends State<_RepaySheet> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.left.toStringAsFixed(2),
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _form,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.debtLeft(context.money(widget.left)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _amount,
              label: l10n.fieldAmount,
              suffix: const Text('TJS'),
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => Validators.amount(v, l10n),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.commonSave,
              onPressed: () {
                if (!(_form.currentState?.validate() ?? false)) return;
                Navigator.of(context).pop(Validators.parseAmount(_amount.text));
              },
            ),
          ],
        ),
      ),
    );
  }
}
