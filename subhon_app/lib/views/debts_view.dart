import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/debt_kind.dart';
import '../models/debt_model.dart';
import '../viewmodels/debts_view_model.dart';
import '../widgets/app_button.dart';
import 'debt_details_view.dart';
import 'debt_form_view.dart';

/// The "Долги" tab: an overview (owed to me, debts to people, credits),
/// the "Мне должны | Я должен" switch with its list (or an empty state
/// with "Добавить долг"), and the active credits. Kept on the phone.
class DebtsView extends StatelessWidget {
  const DebtsView({super.key});

  static Future<void> openForm(
    BuildContext context,
    DebtKind kind, {
    DebtModel? debt,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<DebtsViewModel>(),
        child: DebtFormView(kind: kind, initial: debt),
      ),
    ),
  );

  static Future<void> openDetails(BuildContext context, DebtModel debt) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ChangeNotifierProvider.value(
            value: context.read<DebtsViewModel>(),
            child: DebtDetailsView(debtId: debt.id),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<DebtsViewModel>();
    final shown = vm.shown;
    final kind = vm.showIOwe ? DebtKind.iOwe : DebtKind.owedToMe;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.background,
        title: Text(l10n.debtsTitle),
      ),
      // The phone's storage answers at once: no spinner while reading.
      body: !vm.hasData
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xxxl * 2,
              ),
              children: [
                Text(
                  l10n.debtsOverview,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _Card(
                  child: Column(
                    children: [
                      _OverviewRow(
                        icon: Icons.south_west_rounded,
                        color: p.success,
                        title: l10n.debtsOwedToMe,
                        caption: l10n.debtsPeople(vm.owedToMePeople),
                        amount: vm.owedToMeTotal,
                      ),
                      Divider(height: 1, color: p.border),
                      _OverviewRow(
                        icon: Icons.north_east_rounded,
                        color: p.primary,
                        title: l10n.debtsToPeople,
                        caption: l10n.debtsCount(vm.iOwe.length),
                        amount: vm.iOweTotal,
                      ),
                      Divider(height: 1, color: p.border),
                      _OverviewRow(
                        icon: Icons.account_balance_outlined,
                        color: p.error,
                        title: l10n.debtsLoans,
                        caption: l10n.debtsCount(vm.loans.length),
                        amount: vm.loansTotal,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: p.surfaceMuted,
                    borderRadius: AppRadius.lgAll,
                  ),
                  child: Row(
                    children: [
                      for (final (iOwe, label) in [
                        (false, l10n.debtsOwedToMe),
                        (true, l10n.debtsIOwe),
                      ])
                        Expanded(
                          child: Material(
                            color: vm.showIOwe == iOwe
                                ? p.primary
                                : Colors.transparent,
                            borderRadius: AppRadius.mdAll,
                            child: InkWell(
                              borderRadius: AppRadius.mdAll,
                              onTap: () => vm.showTab(iOwe: iOwe),
                              child: SizedBox(
                                height: 46,
                                child: Center(
                                  child: Text(
                                    label,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: vm.showIOwe == iOwe
                                          ? p.onPrimary
                                          : p.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (shown.isEmpty)
                  _EmptyDebts(
                    iOwe: vm.showIOwe,
                    onAdd: () => openForm(context, kind),
                  )
                else ...[
                  for (final debt in shown) ...[
                    _DebtCard(debt: debt, today: vm.today),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => openForm(context, kind),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.debtsAdd),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.debtsActiveLoans,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    TextButton(
                      onPressed: () => openForm(context, DebtKind.credit),
                      child: Text(l10n.debtsAddLoan),
                    ),
                  ],
                ),
                if (vm.loans.isEmpty)
                  Text(l10n.debtsNoLoans, style: theme.textTheme.bodySmall)
                else
                  for (final loan in vm.loans) ...[
                    _DebtCard(debt: loan, today: vm.today),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                if (vm.closed.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.debtsClosed, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  for (final debt in vm.closed.take(10)) ...[
                    _DebtCard(debt: debt, today: vm.today),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.debtsLocalNote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    decoration: BoxDecoration(
      color: context.palette.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      border: Border.all(color: context.palette.border),
    ),
    child: child,
  );
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.caption,
    required this.amount,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String caption;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                Text(caption, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            context.money(amount),
            style: theme.textTheme.titleMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// No debts on this side: a round icon, a title, a hint and the button.
class _EmptyDebts extends StatelessWidget {
  const _EmptyDebts({required this.iOwe, required this.onAdd});

  final bool iOwe;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final color = iOwe ? p.primary : p.success;
    return Column(
      children: [
        const SizedBox(height: AppSpacing.md),
        CircleAvatar(
          radius: 36,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            iOwe ? Icons.north_east_rounded : Icons.south_west_rounded,
            color: color,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          iOwe ? l10n.debtsEmptyIOweTitle : l10n.debtsEmptyOwedTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          iOwe ? l10n.debtsEmptyIOweMessage : l10n.debtsEmptyOwedMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: 240,
          child: AppButton(
            label: l10n.debtsAdd,
            icon: Icons.add_rounded,
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}

/// One debt or credit: who, what is left of how much, a progress bar and
/// the due date (red when overdue). Tap for details.
class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt, required this.today});

  final DebtModel debt;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final color = switch (debt.kind) {
      DebtKind.owedToMe => p.success,
      DebtKind.iOwe => p.primary,
      _ => p.error,
    };
    final overdue = debt.isOverdue(today);
    final due = debt.dueDate;
    return Material(
      color: p.surface,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => DebtsView.openDetails(context, debt),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Text(
                      debt.name.isEmpty ? '?' : debt.name.substring(0, 1),
                      style: theme.textTheme.titleSmall?.copyWith(color: color),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          debt.isClosed
                              ? l10n.debtClosedBadge
                              : due == null
                              ? l10n.debtNoDueDate
                              : overdue
                              ? l10n.debtOverdue(context.formatShortDate(due))
                              : l10n.debtDue(context.formatShortDate(due)),
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
                        context.money(
                          debt.isClosed ? debt.amount : debt.remaining,
                        ),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: debt.isClosed ? p.textSecondary : color,
                        ),
                      ),
                      if (!debt.isClosed && debt.paid > 0)
                        Text(
                          '/ ${context.money(debt.amount)}',
                          style: theme.textTheme.labelSmall,
                        ),
                    ],
                  ),
                ],
              ),
              if (!debt.isClosed && debt.paid > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(99)),
                  child: LinearProgressIndicator(
                    value: debt.progress,
                    minHeight: 6,
                    backgroundColor: p.surfaceMuted,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
