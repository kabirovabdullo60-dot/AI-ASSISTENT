import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/disbursement_model.dart';
import '../models/payroll_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../viewmodels/settings_view_model.dart';
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
    final csv = StringBuffer('Employee,Role,Store,Tenure months,Salary,Disbursed,Remaining,Status\n');
    for (final p in vm.items) {
      csv.writeln(
        '"${p.employeeName}","${p.role}","${p.storeName}",${p.tenureMonths},${p.salary},${p.disbursed},${p.remaining},${p.status.label}',
      );
    }
    Clipboard.setData(ClipboardData(text: csv.toString()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Ledger for ${formatMonthYear(vm.month)} copied as CSV')));
  }

  @override
  Widget build(BuildContext context) {
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
            'ENTERPRISE PORTAL',
            'FISCAL YEAR ${vm.month.year}',
            'LEDGER ${ApiConstants.payroll.toUpperCase()}',
          ],
          title: 'Salaries & Payroll Management',
          subtitle:
              'Manage monthly employee remuneration, record disbursements and track outstanding balances across all regional hubs.',
          actions: [
            OutlinedButton.icon(
              onPressed: () => _export(context, vm),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Export Ledger'),
            ),
            FilledButton.icon(
              key: const Key('record-salary'),
              onPressed: vm.pendingCount == 0 ? null : () => SalaryPaymentDialog.show(context),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Record Salary Payment'),
            ),
          ],
          children: [
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                columns: c.maxWidth >= 900 ? 4 : 2,
                children: [
                  KpiCard(
                    title: 'Total Monthly Payroll',
                    value: cur.amount(vm.totalPayroll),
                    unit: cur.code,
                    icon: Icons.account_balance_outlined,
                    badge: month,
                    badgeTone: BadgeTone.info,
                    caption: 'Allocated monthly budget',
                  ),
                  KpiCard(
                    title: 'Total Disbursed',
                    value: cur.amount(vm.disbursedTotal),
                    unit: cur.code,
                    icon: Icons.check_circle_outline,
                    badge: '${(vm.disbursedRatio * 100).toStringAsFixed(1)}% disbursed',
                    badgeIcon: Icons.trending_up,
                    caption: 'Settled',
                  ),
                  KpiCard(
                    title: 'Total Outstanding',
                    value: cur.amount(vm.pendingTotal),
                    unit: cur.code,
                    icon: Icons.pending_actions_outlined,
                    badge: '${((1 - vm.disbursedRatio) * 100).toStringAsFixed(1)}% balance',
                    badgeTone: BadgeTone.warning,
                    badgeDot: true,
                    caption: 'Pending clearance',
                    highlight: true,
                  ),
                  KpiCard(
                    title: 'Staff Distribution',
                    value: '${vm.items.length} Employees',
                    icon: Icons.badge_outlined,
                    badge: '${vm.branchCount} Branches',
                    badgeTone: BadgeTone.info,
                    caption: '100% active contracts',
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
                      columns: const [
                        'EMPLOYEE & POSITION',
                        'ASSIGNED STORE',
                        'TENURE',
                        'MONTHLY SALARY',
                        'DISBURSED',
                        'REMAINING',
                        'STATUS',
                        'ACTIONS',
                      ],
                      numeric: const {3, 4, 5},
                      empty: vm.items.isEmpty ? 'No payroll for $month yet' : 'No employees match the filters',
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
                      extra: 'Filtered Batch: ${formatMonthYear(vm.month)}',
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
      StatusBadge(formatTenure(p.tenureMonths), tone: BadgeTone.info),
      money(p.salary),
      money(p.disbursed, color: p.status == PayStatus.paid ? AppColors.green : null),
      money(p.remaining, color: p.remaining > 0 ? AppColors.red : AppColors.muted),
      StatusBadge(p.status.label, tone: tone, dot: true),
      p.remaining > 0 && vm.isCurrentMonth
          ? FilledButton.icon(
              key: Key('pay-${p.id}'),
              style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
              onPressed: vm.payingId == null ? () => SalaryPaymentDialog.show(context, payroll: p) : null,
              icon: const Icon(Icons.payments_outlined, size: 16),
              label: const Text('Record Payment'),
            )
          : TextButton.icon(
              key: Key('history-${p.id}'),
              onPressed: () => PayrollHistoryDialog.show(context, p),
              icon: const Icon(Icons.receipt_long_outlined, size: 16),
              label: const Text('History'),
            ),
    ];
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.vm});

  final PayrollViewModel vm;

  @override
  Widget build(BuildContext context) {
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
                        tooltip: 'Previous month',
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
                        tooltip: 'Next month',
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
                  label: vm.storeFilter ?? 'All Stores (${vm.storeNames.length})',
                  value: vm.storeFilter ?? '',
                  onSelected: (s) => vm.setStoreFilter(s.isEmpty ? null : s),
                  items: [('', 'All Stores'), for (final s in vm.storeNames) (s, s)],
                ),
                SizedBox(
                  width: 280,
                  child: TextField(
                    key: const Key('payroll-search'),
                    onChanged: vm.setQuery,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search by staff name or position…',
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
              labels: [for (final t in PayrollTab.values) '${t.label} (${vm.countFor(t)})'],
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
    final rows = vm.budgetByStore;
    final max = rows.isEmpty ? 1.0 : rows.first.total;
    const colors = [AppColors.navy, AppColors.orange, Color(0xFF4B5675), Color(0xFFB8C0D6)];
    final now = DateTime.now();
    return SectionCard(
      title: 'Store Budget Allocation',
      badge: StatusBadge(
        vm.pendingTotal == 0 ? 'Balanced' : 'Open balance',
        tone: vm.pendingTotal == 0 ? BadgeTone.positive : BadgeTone.warning,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rows.isEmpty) const Text('No payroll for this month'),
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('${rows[i].store} (${rows[i].staff} staff)', style: const TextStyle(fontSize: 13)),
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
              const Expanded(
                child: Text('Synced with ERP General Ledger', style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
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

  final List<DisbursementModel> items;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Recent Payroll Disbursements',
      subtitle: 'Real-time payment audit log across retail branches',
      trailing: TextButton(
        style: TextButton.styleFrom(foregroundColor: AppColors.orange),
        onPressed: () => context.read<HomeViewModel>().select(AppSection.dashboard),
        child: const Text('View Full Audit →', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      child: Column(
        children: [
          if (items.isEmpty)
            const Padding(padding: EdgeInsets.all(12), child: Text('No payments recorded this month'))
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
                            d.method.startsWith('Bank') ? Icons.account_balance_outlined : Icons.payments_outlined,
                            size: 30,
                            color: d.part.isEmpty ? AppColors.green : AppColors.orange,
                            background: d.part.isEmpty ? AppColors.greenSoft : AppColors.orangeSoft,
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
                                  '${d.part.isEmpty ? d.method : d.part} • ${d.reference}',
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
                                '${formatRelativeDay(d.time)}, ${formatTime(d.time)}',
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
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.orange),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All bank settlements follow National Bank standard formats and are signed via TLS.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
