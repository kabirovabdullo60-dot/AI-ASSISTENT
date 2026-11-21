import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/sale_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/sales_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/app_table.dart';
import '../widgets/async_content.dart';
import '../widgets/dropdown_chip.dart';
import '../widgets/icon_box.dart';
import '../widgets/page_body.dart';
import '../widgets/pager.dart';
import '../widgets/pill_tabs.dart';
import '../widgets/section_card.dart';
import '../widgets/sparkline.dart';
import '../widgets/status_badge.dart';
import 'record_sale_dialog.dart';
import 'sale_entry_form_view.dart';
import '../core/motion/app_dialog.dart';

/// "Sales & Daily Entries" — /api/sales (+ daily / weekly / monthly reports).
class SalesView extends StatelessWidget {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<SalesViewModel>();
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    return AsyncContent(
      hasData: vm.hasData,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) => PageBody(
        eyebrow: [tr.salesEyebrow],
        title: tr.salesTitle,
        subtitle: tr.salesSubtitle,
        actions: [
          _TotalChip(label: tr.totalToday, value: vm.todayTotal, icon: Icons.today_outlined, currency: cur),
          _TotalChip(
            label: tr.totalThisMonth,
            value: vm.monthTotal,
            icon: Icons.calendar_month_outlined,
            currency: cur,
          ),
        ],
        children: [
          if (vm.lastSaved != null) ...[
            _SuccessBanner(sale: vm.lastSaved!, onClose: vm.dismissBanner),
            const SizedBox(height: 16),
          ],
          LayoutBuilder(
            builder: (context, c) {
              const form = Card(
                child: Padding(padding: EdgeInsets.all(20), child: SaleEntryFormView()),
              );
              final right = _EntriesColumn(vm: vm, currency: cur);
              if (c.maxWidth < 1000) {
                return Column(children: [form, const SizedBox(height: 16), right]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 340, child: form),
                  const SizedBox(width: 16),
                  Expanded(child: right),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  const _TotalChip({required this.label, required this.value, required this.icon, required this.currency});

  final String label;
  final double value;
  final IconData icon;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBox(icon, color: AppColors.orange, background: AppColors.orangeSoft),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: AppColors.muted)),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: currency.amount(value),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: ' ${currency.code}',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.sale, required this.onClose});

  final SaleModel sale;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return Card(
      key: const Key('sale-success'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: AppColors.greenSoft,
              child: Icon(Icons.check, size: 16, color: AppColors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13.5),
                  children: [
                    TextSpan(
                      text: tr.successPrefix,
                      style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: tr.saleSavedMessage('${formatAmount(sale.amount)} TJS', sale.storeName)),
                  ],
                ),
              ),
            ),
            IconButton(
              key: const Key('dismiss-banner'),
              tooltip: tr.close,
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntriesColumn extends StatelessWidget {
  const _EntriesColumn({required this.vm, required this.currency});

  final SalesViewModel vm;
  final Currency currency;

  void _export(BuildContext context, List<SaleModel> rows) {
    final csv = StringBuffer('Date,Store,Amount TJS,Description,Id\n');
    for (final s in rows) {
      csv.writeln('${isoDayText(s.saleDate)},"${s.storeName}",${s.amount},"${s.description ?? ''}",${s.id}');
    }
    Clipboard.setData(ClipboardData(text: csv.toString()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.rowsCopied(rows.length))));
  }

  static String isoDayText(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: vm.customFrom ?? now.subtract(const Duration(days: 6)),
        end: vm.customTo ?? now,
      ),
    );
    if (range != null) vm.setCustomRange(range.start, range.end);
  }

  Future<void> _delete(BuildContext context, SaleModel sale) async {
    final tr = context.l10n;
    final ok = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.deleteSaleTitle),
        content: Text(tr.deleteSaleBody(currency.format(sale.amount), sale.storeName, formatDate(sale.saleDate))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr.cancel)),
          FilledButton(
            key: const Key('confirm-delete-sale'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final dashboard = context.read<DashboardViewModel>();
    final stores = context.read<StoresViewModel>();
    final error = await vm.deleteSale(sale);
    if (error == null) {
      dashboard.load();
      stores.load();
    }
    if (context.mounted) showResult(context, error, success: tr.saleDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final stores = context.watch<StoresViewModel>();
    final query = context.select<HomeViewModel, String>((h) => h.query);
    final rows = vm.filtered(query);
    final change = vm.changeVsPrevious();
    final week = vm.last7Days;
    var peak = 0;
    for (var i = 1; i < week.length; i++) {
      if (week[i].revenue > week[peak].revenue) peak = i;
    }
    final active = stores.activeCount;
    final reported = vm.storesReportedToday.clamp(0, active == 0 ? 0 : active);
    final ratio = active == 0 ? 0.0 : reported / active;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(tr.storeLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    DropdownChip<String>(
                      key: const Key('sales-store-filter'),
                      label: stores.nameOf(vm.storeFilter) ?? tr.allStores,
                      value: vm.storeFilter ?? '',
                      onSelected: (id) => vm.setStoreFilter(id.isEmpty ? null : id),
                      items: [('', tr.allStores), for (final s in stores.ranked) (s.id, s.name)],
                    ),
                    SizedBox(
                      width: 260,
                      child: TextField(
                        key: const Key('sales-search'),
                        onChanged: vm.setQuery,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: tr.searchEntries,
                          prefixIcon: const Icon(Icons.search, size: 18),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _export(context, rows),
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: Text(tr.export),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    PillTabs(
                      labels: [for (final r in SalesRange.values) tr.salesRange(r)],
                      icons: const {3: Icons.calendar_today_outlined},
                      selected: vm.range.index,
                      onSelect: (i) => SalesRange.values[i] == SalesRange.custom
                          ? _pickRange(context)
                          : vm.setRange(SalesRange.values[i]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          key: const Key('filtered-total'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              IconBox(Icons.calculate_outlined, color: Colors.white, background: AppColors.navy),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr.activeFilterVolume, style: TextStyle(fontSize: 12, color: AppColors.muted)),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(text: tr.filteredTotal),
                          TextSpan(
                            text: currency.format(vm.filteredTotal),
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: tr.acrossEntries(vm.entryCount),
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    if (change != null) ...[
                      const SizedBox(height: 6),
                      StatusBadge(
                        tr.vsPrevPeriod(formatPercent(change)),
                        tone: change >= 0 ? BadgeTone.positive : BadgeTone.negative,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (vm.isLoading) const LinearProgressIndicator(minHeight: 2),
                AppTable(
                  key: const Key('sales-table'),
                  columns: [tr.colDateTime, tr.colStoreName, tr.colSalesAmount, tr.colNotesMethod, ''],
                  numeric: const {2},
                  empty: tr.noEntries,
                  rows: [
                    for (final s in rows)
                      [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: isSameDay(s.saleDate, DateTime.now()) ? AppColors.green : AppColors.barGray,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatRelativeDay(s.saleDate),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  s.createdAt == null ? formatDate(s.saleDate) : formatTime(s.createdAt!.toLocal()),
                                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(s.storeName),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: formatAmount2(currency.fromTjs(s.amount)),
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: ' ${currency.code}',
                                style: TextStyle(fontSize: 11, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: Text(
                            s.description ?? '—',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              key: Key('edit-sale-${s.id}'),
                              tooltip: tr.edit,
                              visualDensity: VisualDensity.compact,
                              onPressed: () => RecordSaleDialog.show(context, sale: s),
                              icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.muted),
                            ),
                            IconButton(
                              key: Key('delete-sale-${s.id}'),
                              tooltip: tr.delete,
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _delete(context, s),
                              icon: Icon(Icons.delete_outline, size: 18, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ],
                  ],
                ),
                const Divider(height: 20),
                Pager(
                  page: vm.page,
                  pageCount: vm.pageCount,
                  pageSize: SalesViewModel.pageSize,
                  itemCount: vm.entryCount,
                  onPage: vm.goToPage,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final weekCard = SectionCard(
              title: tr.salesLast7,
              trailing: week.isEmpty || week[peak].revenue == 0
                  ? null
                  : Text(
                      tr.peakLabel(formatWeekday(week[peak].date), currency.format(week[peak].revenue)),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
              child: Sparkline(values: [for (final p in week) p.revenue]),
            );
            final reportedCard = SectionCard(
              title: tr.storesReported,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(ratio * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          tr.storesReportedValue(reported, active),
                          style: TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 5,
                      color: AppColors.orange,
                      backgroundColor: AppColors.border,
                    ),
                  ),
                ],
              ),
            );
            if (c.maxWidth < 620) return Column(children: [weekCard, const SizedBox(height: 16), reportedCard]);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: weekCard),
                const SizedBox(width: 16),
                Expanded(child: reportedCard),
              ],
            );
          },
        ),
      ],
    );
  }
}
