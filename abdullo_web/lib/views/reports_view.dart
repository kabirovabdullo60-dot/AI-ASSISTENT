import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../viewmodels/assistant_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/reports_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/app_table.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/mini_stat_tile.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';

/// Reports — /api/reports/store-comparison, /employees, /payroll.
class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  void _analyze(BuildContext context) {
    context.read<HomeViewModel>().select(AppSection.assistant);
    context.read<AssistantViewModel>().send(
      context.l10n.analyzeMyReport,
      language: Localizations.localeOf(context).languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<ReportsViewModel>();
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    return AsyncContent(
      hasData: vm.hasData,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) {
        final c = vm.comparison!;
        final emp = vm.employees!;
        final pay = vm.payroll!;
        final ranked = vm.ranked;
        return PageBody(
          title: tr.navReports,
          subtitle: tr.reportsSubtitle,
          actions: [
            FilledButton.icon(
              key: const Key('analyze-report'),
              onPressed: () => _analyze(context),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(tr.analyzeWithAi),
            ),
          ],
          children: [
            LayoutBuilder(
              builder: (context, box) => CardGrid(
                columns: box.maxWidth >= 620 ? 3 : 1,
                children: [
                  MiniStatTile(
                    label: c.changePercent == null
                        ? tr.kpiMonthlySales
                        : tr.monthlySalesChange(formatPercent(c.changePercent!)),
                    value: cur.format(c.totalAmount),
                    icon: Icons.insights_outlined,
                    iconColor: AppColors.green,
                  ),
                  MiniStatTile(label: tr.salesThisMonth, value: tr.salesCount(c.salesCount), icon: Icons.receipt_long),
                  MiniStatTile(
                    label: tr.monthlyPayroll,
                    value: cur.format(emp.monthlySalaryTotal),
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: tr.storeComparisonTitle,
              child: AppTable(
                key: const Key('reports-table'),
                columns: ['#', tr.store, tr.colSales, tr.monthlySalesCol, tr.share, tr.colChange],
                numeric: const {2, 3, 4, 5},
                empty: tr.noSalesThisMonth,
                rows: [
                  for (var i = 0; i < ranked.length; i++)
                    [
                      Text('${ranked[i].rank == 0 ? i + 1 : ranked[i].rank}'),
                      Text(ranked[i].storeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('${ranked[i].salesCount}'),
                      Text(cur.format(ranked[i].totalAmount)),
                      Text('${ranked[i].sharePercent.toStringAsFixed(1)}%', style: TextStyle(color: AppColors.muted)),
                      Text(
                        ranked[i].changePercent == null ? '—' : formatPercent(ranked[i].changePercent!),
                        style: TextStyle(color: (ranked[i].changePercent ?? 0) >= 0 ? AppColors.green : AppColors.red),
                      ),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: tr.payrollYearTitle('${pay.year}'),
              subtitle: tr.salarySummary(
                cur.format(pay.totalDue),
                cur.format(pay.totalPaid),
                cur.format(pay.totalRemaining),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const Key('prev-year'),
                    tooltip: tr.prevYear,
                    onPressed: () => vm.setYear(vm.year - 1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  IconButton(
                    key: const Key('next-year'),
                    tooltip: tr.nextYear,
                    onPressed: vm.year >= DateTime.now().year ? null : () => vm.setYear(vm.year + 1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              child: AppTable(
                key: const Key('payroll-year-table'),
                columns: [tr.colMonth, tr.colEmployees, tr.colDue, tr.colPaid, tr.colRemainingShort],
                numeric: const {1, 2, 3, 4},
                rows: [
                  for (final m in pay.months.where((m) => m.due > 0 || m.paid > 0))
                    [
                      Text(formatMonthYear(DateTime(pay.year, m.month))),
                      Text('${m.employees}'),
                      Text(cur.format(m.due)),
                      Text(cur.format(m.paid)),
                      Text(
                        cur.format(m.remaining),
                        style: TextStyle(
                          color: m.remaining > 0 ? AppColors.ink : AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: tr.byPosition,
              child: AppTable(
                columns: [tr.position, tr.colEmployees, tr.active, tr.monthlyPayroll],
                numeric: const {1, 2, 3},
                rows: [
                  for (final p in emp.byPosition)
                    [Text(p.position), Text('${p.employees}'), Text('${p.active}'), Text(cur.format(p.salaryTotal))],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
