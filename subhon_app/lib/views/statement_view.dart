import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/storage/statement_history_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/statement_excel.dart';
import '../l10n/statement_text.dart';
import '../models/statement_kind.dart';
import '../models/statement_request_model.dart';
import '../models/statement_row_model.dart';
import '../models/statement_total_kind.dart';
import '../services/file_share_service.dart';
import '../services/statement_service.dart';
import '../services/store_service.dart';
import '../viewmodels/session_view_model.dart';
import '../viewmodels/statement_period.dart';
import '../viewmodels/statement_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_error_view.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/options_sheet.dart';

/// One statement or certificate: the period (and store), the totals and
/// every line, and "Скачать Excel" to save or send it as an .xlsx file.
class StatementView extends StatelessWidget {
  const StatementView({required this.kind, this.initial, super.key});

  final StatementKind kind;

  /// Reopened from "Мои выписки": its period and store.
  final StatementRequestModel? initial;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => StatementViewModel(
      context.read<StatementService>(),
      context.read<StoreService>(),
      context.read<FileShareService>(),
      kind: kind,
      initial: initial,
      history: context.read<StatementHistoryStorage>(),
      userId: context.read<SessionViewModel>().user?.id,
    )..start(),
    child: const _Statement(),
  );
}

class _Statement extends StatelessWidget {
  const _Statement();

  Future<void> _pickDates(BuildContext context, StatementViewModel vm) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: vm.startDate == null || vm.endDate == null
          ? null
          : DateTimeRange(start: vm.startDate!, end: vm.endDate!),
    );
    if (range != null) await vm.setDates(range.start, range.end);
  }

  Future<void> _pickStore(BuildContext context, StatementViewModel vm) async {
    final picked = await showOptionsSheet<String>(
      context,
      title: context.l10n.stmtChooseStore,
      selected: vm.storeId,
      options: [for (final s in vm.stores) (s.id, s.name)],
    );
    if (picked == null) return;
    await vm.setStore(vm.stores.firstWhere((s) => s.id == picked));
  }

  Future<void> _export(BuildContext context, StatementViewModel vm) async {
    final l10n = context.l10n;
    final feedback = AppSnackbar.of(context);
    try {
      if (await vm.export((s) => statementToExcel(s, l10n))) {
        feedback.showSuccess(l10n.stmtShared);
      }
    } on Exception {
      feedback.showError(l10n.errUnknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<StatementViewModel>();
    final s = vm.statement;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(title: Text(statementTitle(l10n, vm.kind))),
      bottomNavigationBar: s == null || s.rows.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.md,
                ),
                child: AppButton(
                  label: l10n.stmtExcel,
                  icon: Icons.table_view_outlined,
                  isLoading: vm.isExporting,
                  onPressed: () => _export(context, vm),
                ),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          children: [
            if (vm.kind.needsStore) ...[
              AppPickerField(
                label: l10n.colStore,
                value: vm.storeName,
                placeholder: l10n.stmtChooseStore,
                leading: const Icon(Icons.storefront_outlined),
                enabled: vm.stores.isNotEmpty,
                onTap: () => _pickStore(context, vm),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (vm.kind.hasPeriod) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    for (final (period, label) in [
                      (StatementPeriod.today, l10n.periodToday),
                      (StatementPeriod.week, l10n.historyWeek),
                      (StatementPeriod.month, l10n.periodMonth),
                      (StatementPeriod.lastMonth, l10n.stmtPeriodLastMonth),
                    ]) ...[
                      ChoiceChip(
                        label: Text(label),
                        showCheckmark: false,
                        selected: vm.period == period,
                        onSelected: (_) => vm.setPeriod(period),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    ChoiceChip(
                      avatar: const Icon(Icons.date_range_outlined, size: 18),
                      label: Text(
                        vm.period == StatementPeriod.custom &&
                                vm.startDate != null &&
                                vm.endDate != null
                            ? '${context.formatShortDate(vm.startDate!)} – '
                                  '${context.formatShortDate(vm.endDate!)}'
                            : l10n.stmtPeriodCustom,
                      ),
                      showCheckmark: false,
                      selected: vm.period == StatementPeriod.custom,
                      onSelected: (_) => _pickDates(context, vm),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            if (vm.isLoading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.xxxl),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (vm.error != null)
              AppErrorView(error: vm.error!, onRetry: vm.load)
            else if (s != null) ...[
              if (!s.kind.hasPeriod && s.endDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    l10n.stmtAsOf(context.formatDate(s.endDate!)),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              AppCard(
                child: Column(
                  children: [
                    for (final (kind, amount) in s.totals)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                statementTotalLabel(l10n, kind),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              kind == StatementTotalKind.count
                                  ? '${amount.round()}'
                                  : context.money(amount),
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: switch (kind) {
                                  StatementTotalKind.remaining ||
                                  StatementTotalKind.expenses => p.error,
                                  StatementTotalKind.profit =>
                                    amount >= 0 ? p.success : p.error,
                                  _ => null,
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (s.truncated) ...[
                const SizedBox(height: AppSpacing.md),
                AppInlineMessage(message: l10n.stmtTruncated),
              ],
              const SizedBox(height: AppSpacing.md),
              if (s.rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    l10n.stmtEmpty,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                )
              else
                for (final row in s.rows) ...[
                  _Line(row: row, kind: s.kind),
                  const SizedBox(height: AppSpacing.sm),
                ],
            ] else if (vm.needsStoreChoice)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  l10n.stmtChooseStore,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            if (vm.error != null && vm.statement != null)
              AppInlineMessage(
                type: InlineMessageType.error,
                message: errorText(l10n, vm.error!),
              ),
          ],
        ),
      ),
    );
  }
}

/// One line of the statement on screen.
class _Line extends StatelessWidget {
  const _Line({required this.row, required this.kind});

  final StatementRowModel row;
  final StatementKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = context.palette;
    final detail = switch (row.detail) {
      null => null,
      final String text => text,
      final double share => context.percent(share),
      final other => statementValueText(l10n, other),
    };
    final date = row.date;
    final top = row.title.isNotEmpty ? row.title : (detail ?? '');
    final bottom = [
      if (date != null)
        kind == StatementKind.operations
            ? context.formatDateTime(date)
            : context.formatShortDate(date),
      if (row.title.isNotEmpty && detail != null) detail,
    ].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  top,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                if (bottom.isNotEmpty)
                  Text(
                    bottom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            context.money(
              row.amount,
              signed:
                  row.amount > 0 &&
                  kind != StatementKind.stores &&
                  kind != StatementKind.salaryDebt,
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              color: kind == StatementKind.salaryDebt
                  ? p.error
                  : row.amount > 0
                  ? p.success
                  : p.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
