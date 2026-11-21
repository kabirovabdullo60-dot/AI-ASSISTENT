import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/storage/statement_history_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../l10n/statement_text.dart';
import '../models/statement_kind.dart';
import '../models/statement_request_model.dart';
import '../viewmodels/session_view_model.dart';
import '../viewmodels/statements_view_model.dart';
import 'statement_view.dart';

/// "Выписки и справки": the certificates (who is owed salary, profit,
/// stores summary) and statements (sales, one store, cash, card and QR,
/// expenses, salary payments, all operations), each opened for a period
/// and exported to Excel; "Мои выписки" lists those opened before.
class StatementsView extends StatelessWidget {
  const StatementsView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => StatementsViewModel(
      context.read<StatementHistoryStorage>(),
      context.read<SessionViewModel>().user?.id,
    )..load(),
    child: const _Statements(),
  );
}

class _Statements extends StatelessWidget {
  const _Statements();

  Future<void> _open(
    BuildContext context,
    StatementKind kind, {
    StatementRequestModel? request,
  }) async {
    final vm = context.read<StatementsViewModel>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatementView(kind: kind, initial: request),
      ),
    );
    await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<StatementsViewModel>();
    Widget section(String title, List<StatementKind> kinds) => _Section(
      title: title,
      children: [
        for (final kind in kinds)
          _Row(
            icon: statementIcon(kind),
            title: statementTitle(l10n, kind),
            subtitle: statementHint(l10n, kind),
            onTap: () => _open(context, kind),
          ),
      ],
    );
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        backgroundColor: p.surface,
        title: Text(l10n.stmtTitle),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: l10n.stmtAvailable,
                    selected: !vm.showMine,
                    onTap: () => vm.showTab(mine: false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TabButton(
                    label: l10n.stmtMine,
                    selected: vm.showMine,
                    onTap: () => vm.showTab(mine: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: vm.showMine
            ? [
                if (vm.mine.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      l10n.stmtMineEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  _Section(
                    title: l10n.stmtMine,
                    children: [
                      for (final r in vm.mine)
                        _Row(
                          icon: statementIcon(r.kind),
                          title: [
                            statementTitle(l10n, r.kind),
                            ?r.storeName,
                          ].join(' · '),
                          subtitle: r.startDate == null || r.endDate == null
                              ? l10n.stmtAsOf(
                                  context.formatShortDate(r.openedAt),
                                )
                              : '${context.formatShortDate(r.startDate!)} – '
                                    '${context.formatShortDate(r.endDate!)}',
                          onTap: () => _open(context, r.kind, request: r),
                        ),
                    ],
                  ),
              ]
            : [
                section(l10n.stmtCertificates, const [
                  StatementKind.salaryDebt,
                  StatementKind.profit,
                  StatementKind.stores,
                ]),
                const SizedBox(height: AppSpacing.lg),
                section(l10n.stmtStatements, const [
                  StatementKind.sales,
                  StatementKind.store,
                  StatementKind.cash,
                  StatementKind.card,
                  StatementKind.expenses,
                  StatementKind.salaries,
                  StatementKind.operations,
                ]),
              ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? p.primary : p.surfaceMuted,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? p.onPrimary : p.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A white rounded block with a bold title, a line and rows.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Divider(height: 1, color: p.border),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: p.primaryLight,
              child: Icon(icon, color: p.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: p.textSecondary),
          ],
        ),
      ),
    );
  }
}
