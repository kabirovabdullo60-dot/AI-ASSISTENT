import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/constants/api_constants.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/payment_model.dart';
import '../models/payroll_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/app_table.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/dropdown_chip.dart';
import '../widgets/icon_box.dart';
import '../widgets/kpi_card.dart';
import '../widgets/page_body.dart';
import '../widgets/pager.dart';
import '../widgets/pill_tabs.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import 'payroll_history_dialog.dart';
import 'salary_payment_dialog.dart';

/// "Salaries & Payroll Management" from the Figma.
class SalariesView extends StatelessWidget {
  const SalariesView({super.key});

  void _export(BuildContext context, PayrollViewModel vm) {
    final csv = StringBuffer('Employee,Position,Store,Worked days,Due,Paid,Remaining,Status\n');
    for (final p in vm.items) {
      csv.writeln(
        '"${p.employeeName}","${p.role}","${p.storeName}",${p.workedDays},${p.salary},${p.disbursed},${p.remaining},${p.status.name.toUpperCase()}',
      );
    }
    Clipboard.setData(ClipboardData(text: csv.toString()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.ledgerCopied(formatMonthYear(vm.month)))));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<PayrollViewModel>();
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);
    final query = context.select<HomeViewModel, String>((h) => h.query);

    return AsyncContent(
      hasData: vm.hasData,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) {
        final rows = vm.filtered(query);
        final page = vm.pageItems(rows);
        final month = '${formatMonth(vm.month)} ${vm.month.year}';
        return PageBody(
          eyebrow: [
            tr.payrollEyebrow,
            tr.fiscalYear('${vm.month.year}'),
            tr.ledger(ApiConstants.payroll.toUpperCase()),
          ],
          title: tr.payrollTitle,
          subtitle: tr.payrollSubtitle,
          actions: [
            OutlinedButton.icon(
              onPressed: () => _export(context, vm),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: Text(tr.exportLedger),
            ),
            FilledButton.icon(
              key: const Key('record-salary'),
              onPressed: vm.pendingCount == 0 ? null : () => SalaryPaymentDialog.show(context),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(tr.recordSalaryPayment),
            ),
          ],
          children: [
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                columns: c.maxWidth >= 900 ? 4 : 2,
                children: [
                  KpiCard(
                    title: tr.totalMonthlyPayroll,
                    value: cur.amount(vm.totalPayroll),
                    unit: cur.code,
                    icon: Icons.account_balance_outlined,
                    badge: month,
                    badgeTone: BadgeTone.info,
                    caption: tr.allocatedBudget,
                  ),
                  KpiCard(
                    title: tr.totalDisbursed,
                    value: cur.amount(vm.disbursedTotal),
                    unit: cur.code,
                    icon: Icons.check_circle_outline,
                    badge: tr.pctDisbursed((vm.disbursedRatio * 100).toStringAsFixed(1)),
                    badgeIcon: Icons.trending_up,
                    caption: tr.settled,
                  ),
                  KpiCard(
                    title: tr.totalOutstanding,
                    value: cur.amount(vm.pendingTotal),
                    unit: cur.code,
                    icon: Icons.pending_actions_outlined,
                    badge: tr.pctBalance(((1 - vm.disbursedRatio) * 100).toStringAsFixed(1)),
                    badgeTone: BadgeTone.warning,
                    badgeDot: true,
                    caption: tr.pendingClearance,
                    highlight: true,
                  ),
                  KpiCard(
                    title: tr.staffDistribution,
                    value: tr.nEmployees(vm.items.length),
                    icon: Icons.badge_outlined,
                    badge: tr.nBranches(vm.branchCount),
                    badgeTone: BadgeTone.info,
                    caption: tr.activeContracts,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Filters(vm: vm),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppTable(
                      key: const Key('payroll-table'),
                      columns: [
                        tr.colEmployee,
                        tr.colAssignedStore,
                        tr.colTenure,
                        tr.colMonthlySalary,
                        tr.colDisbursed,
                        tr.colRemaining,
                        tr.colStatus,
                        tr.colActions,
                      ],
                      numeric: const {3, 4, 5},
                      empty: vm.items.isEmpty ? tr.noPayrollFor(month) : tr.noEmployeesMatch,
                      rows: [for (final p in page) _row(context, p, cur, vm)],
                    ),
                    const Divider(height: 20),
                    Pager(
                      page: vm.page,
                      pageCount: vm.pageCount(rows.length),
                      pageSize: PayrollViewModel.pageSize,
                      itemCount: rows.length,
                      onPage: vm.goToPage,
                      noun: 'employees',
                      extra: tr.filteredBatch(formatMonthYear(vm.month)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final budget = _BudgetCard(vm: vm, currency: cur);
                final paid = _DisbursementsCard(items: vm.disbursements.take(4).toList(), currency: cur);
                if (c.maxWidth < 1000) return Column(children: [budget, const SizedBox(height: 16), paid]);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: budget),
                    const SizedBox(width: 16),
                    Expanded(flex: 3, child: paid),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> _row(BuildContext context, PayrollModel p, Currency cur, PayrollViewModel vm) {
    Widget money(double v, {Color? color}) => Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: cur.amount(v),
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
          TextSpan(
            text: ' ${cur.code}',
            style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
          ),
        ],
      ),
    );
    final (BadgeTone tone, Color avatar) = switch (p.status) {
      PayStatus.paid => (BadgeTone.positive, AppColors.navy),
      PayStatus.partial => (BadgeTone.warning, AppColors.orange),
      PayStatus.unpaid => (BadgeTone.negative, AppColors.barGray),
    };
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: avatar,
            child: Text(
              initials(p.employeeName),
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.employeeName, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(p.role, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
            ],
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
          const SizedBox(width: 4),
          Text(p.storeName),
        ],
      ),
      StatusBadge(context.l10n.workedDays(p.workedDays), tone: BadgeTone.info),
      money(p.salary),
      money(p.disbursed, color: p.status == PayStatus.paid ? AppColors.green : null),
      money(p.remaining, color: p.remaining > 0 ? AppColors.red : AppColors.muted),
      StatusBadge(context.l10n.payStatus(p.status), tone: tone, dot: true),
      p.remaining > 0 && !vm.isFutureMonth
          ? FilledButton.icon(
              key: Key('pay-${p.id}'),
              style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
              onPressed: vm.payingId == null ? () => SalaryPaymentDialog.show(context, payroll: p) : null,
              icon: const Icon(Icons.payments_outlined, size: 16),
              label: Text(context.l10n.recordPayment),
            )
          : TextButton.icon(
              key: Key('history-${p.id}'),
              onPressed: () => PayrollHistoryDialog.show(context, p),
              icon: const Icon(Icons.receipt_long_outlined, size: 16),
              label: Text(context.l10n.history),
            ),
    ];
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.vm});

  final PayrollViewModel vm;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final stores = context.watch<StoresViewModel>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: const Key('prev-month'),
                        tooltip: tr.prevMonth,
                        visualDensity: VisualDensity.compact,
                        onPressed: vm.previousMonth,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.orange),
                      const SizedBox(width: 6),
                      Text(
                        formatMonthYear(vm.month),
                        key: const Key('payroll-month'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        key: const Key('next-month'),
                        tooltip: tr.nextMonth,
                        visualDensity: VisualDensity.compact,
                        onPressed: vm.isCurrentMonth ? null : vm.nextMonth,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
                DropdownChip<String>(
                  key: const Key('payroll-store-filter'),
                  icon: Icons.storefront_outlined,
                  label: stores.nameOf(vm.storeFilter) ?? tr.allStoresCount(stores.stores.length),
                  value: vm.storeFilter ?? '',
                  onSelected: (s) => vm.setStoreFilter(s.isEmpty ? null : s),
                  items: [('', tr.allStores), for (final s in stores.ranked) (s.id, s.name)],
                ),
                SizedBox(
                  width: 280,
                  child: TextField(
                    key: const Key('payroll-search'),
                    onChanged: vm.setQuery,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: tr.searchStaff,
                      prefixIcon: Icon(Icons.search, size: 18),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            PillTabs(
              dark: false,
              labels: [for (final t in PayrollTab.values) tr.tabCount(tr.payrollTab(t), vm.countFor(t))],
              selected: vm.tab.index,
              onSelect: (i) => vm.setTab(PayrollTab.values[i]),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.vm, required this.currency});

  final PayrollViewModel vm;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final rows = vm.budgetByStore;
    final max = rows.isEmpty ? 1.0 : rows.first.total;
    const colors = [AppColors.navy, AppColors.orange, Color(0xFF4B5675), Color(0xFFB8C0D6)];
    final now = DateTime.now();
    return SectionCard(
      title: tr.budgetTitle,
      badge: StatusBadge(
        vm.pendingTotal == 0 ? tr.balanced : tr.openBalance,
        tone: vm.pendingTotal == 0 ? BadgeTone.positive : BadgeTone.warning,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rows.isEmpty) Text(tr.noPayrollMonth),
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(tr.storeStaff(rows[i].store, rows[i].staff), style: const TextStyle(fontSize: 13)),
                      ),
                      Text(
                        currency.format(rows[i].total),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: max == 0 ? 0 : rows[i].total / max,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      color: colors[i % colors.length],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(tr.erpSynced, style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
              ),
              Text(
                '${formatDay(now)}, ${formatTime(now)}',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DisbursementsCard extends StatelessWidget {
  const _DisbursementsCard({required this.items, required this.currency});

  final List<PaymentModel> items;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return SectionCard(
      title: tr.recentDisbursements,
      subtitle: tr.disbursementsSubtitle,
      trailing: TextButton(
        style: TextButton.styleFrom(foregroundColor: AppColors.orange),
        onPressed: () => context.read<HomeViewModel>().select(AppSection.dashboard),
        child: Text(tr.viewFullAudit, style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      child: Column(
        children: [
          if (items.isEmpty)
            Padding(padding: EdgeInsets.all(12), child: Text(tr.noPaymentsMonth))
          else
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                key: const Key('disbursements'),
                columns: c.maxWidth >= 560 ? 2 : 1,
                children: [
                  for (final d in items)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          IconBox(
                            Icons.payments_outlined,
                            size: 30,
                            color: d.status == PayStatus.paid ? AppColors.green : AppColors.orange,
                            background: d.status == PayStatus.paid ? AppColors.greenSoft : AppColors.orangeSoft,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.employeeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                Text(
                                  '${tr.payStatus(d.status)} • ${formatMonthYear(DateTime(d.year, d.month))}${(d.note ?? '').isEmpty ? '' : ' • ${d.note}'}',
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '+${currency.format(d.amount)}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              Text(
                                formatRelativeDay(d.paymentDate),
                                style: const TextStyle(fontSize: 11, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.orange),
                SizedBox(width: 10),
                Expanded(child: Text(tr.bankNote, style: TextStyle(fontSize: 12.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
