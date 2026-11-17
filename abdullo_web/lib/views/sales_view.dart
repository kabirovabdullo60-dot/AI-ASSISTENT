import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/sale_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/profile_view_model.dart';
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
import 'sale_entry_form_view.dart';

/// "Sales & Daily Entries" from the Figma.
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
              const form = _FormCard();
              final right = _EntriesColumn(vm: vm, currency: cur);
              if (c.maxWidth < 1000) {
                return Column(
                  children: [form, const SizedBox(height: 16), const _ClerkCard(), const SizedBox(height: 16), right],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 340, child: Column(children: [form, SizedBox(height: 16), _ClerkCard()])),
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
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 0.6,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: currency.amount(value),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: ' ${currency.code}',
                        style: const TextStyle(fontSize: 11, color: AppColors.muted),
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
            const CircleAvatar(
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

class _FormCard extends StatelessWidget {
  const _FormCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(padding: EdgeInsets.all(20), child: SaleEntryFormView()),
  );
}

class _ClerkCard extends StatelessWidget {
  const _ClerkCard();

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final p = context.watch<ProfileViewModel>().profile;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const IconBox(Icons.verified_user_outlined, color: AppColors.navy, background: AppColors.blueSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr.sessionClerk, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  Text(
                    p == null ? '…' : '${p.name} · ${p.role}',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            StatusBadge(tr.authorized, tone: BadgeTone.positive),
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
    final csv = StringBuffer('Date,Store,Amount TJS,Registered By,Split,Notes,Reference\n');
    for (final s in rows) {
      csv.writeln(
        '${s.date.toIso8601String()},"${s.storeName}",${s.amount},"${s.registeredBy}",${s.split.label},"${s.notes}",${s.reference}',
      );
    }
    Clipboard.setData(ClipboardData(text: csv.toString()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.rowsCopied(rows.length))));
  }

  Future<void> _pickRange(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: vm.customFrom ?? now.subtract(const Duration(days: 6)),
        end: vm.customTo ?? now,
      ),
    );
    if (range != null) vm.setCustomRange(range.start, range.end);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final stores = context.watch<StoresViewModel>();
    final query = context.select<HomeViewModel, String>((h) => h.query);
    final rows = vm.filtered(query);
    final page = vm.pageItems(rows);
    final change = vm.changeVsPrevious();
    final minutes = DateTime.now().difference(vm.updatedAt).inMinutes;
    final hourly = vm.hourlyToday;
    final peakHour = hourly.indexOf(hourly.reduce((a, b) => a > b ? a : b));
    final active = stores.activeCount;
    final synced = vm.storesSyncedToday.clamp(0, active == 0 ? 1 : active);
    final ratio = active == 0 ? 0.0 : synced / active;

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
                    Text(tr.storeLabel, style: TextStyle(fontWeight: FontWeight.w600)),
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
                          hintText: tr.searchReceipt,
                          prefixIcon: Icon(Icons.search, size: 18),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
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
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        children: [
                          const TextSpan(
                            text: '● ',
                            style: TextStyle(color: AppColors.orange),
                          ),
                          TextSpan(text: minutes < 1 ? tr.updatedJustNow : tr.updatedMinutesAgo(minutes)),
                        ],
                      ),
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
          decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const IconBox(Icons.calculate_outlined, color: Colors.white, background: AppColors.navy),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.activeFilterVolume,
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 14),
                        children: [
                          TextSpan(text: tr.filteredTotal),
                          TextSpan(
                            text: currency.format(vm.filteredTotal(query)),
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: tr.acrossEntries(rows.length),
                            style: const TextStyle(color: AppColors.muted),
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
                AppTable(
                  key: const Key('sales-table'),
                  columns: [tr.colDateTime, tr.colStoreName, tr.colSalesAmount, tr.colRegisteredBy, tr.colNotesMethod],
                  numeric: const {2},
                  empty: tr.noEntries,
                  rows: [
                    for (final s in page)
                      [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: isSameDay(s.date, DateTime.now()) ? AppColors.green : AppColors.barGray,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(formatRelativeDay(s.date), style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text(formatTime(s.date), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
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
                                style: const TextStyle(fontSize: 11, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.surfaceSoft,
                              child: Text(
                                initials(s.registeredBy.replaceAll('.', ' ')),
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(s.registeredBy),
                          ],
                        ),
                        s.notes.contains('POS') || s.notes.contains('Card')
                            ? StatusBadge(s.notes, tone: BadgeTone.info, icon: Icons.credit_card)
                            : Text(
                                s.notes.isEmpty ? tr.split(s.split) : s.notes,
                                style: const TextStyle(color: AppColors.muted),
                              ),
                      ],
                  ],
                ),
                const Divider(height: 20),
                Pager(
                  page: vm.page,
                  pageCount: vm.pageCount(rows.length),
                  pageSize: SalesViewModel.pageSize,
                  itemCount: rows.length,
                  onPage: vm.goToPage,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final hourlyCard = SectionCard(
              title: tr.hourlyVelocity,
              trailing: Text(
                tr.peakLabel(
                  '${(peakHour + 8).toString().padLeft(2, '0')}:00',
                  '${formatCompact(currency.fromTjs(hourly[peakHour]))} ${currency.code}',
                ),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 11.5, color: AppColors.green, fontWeight: FontWeight.w600),
              ),
              child: Sparkline(values: hourly),
            );
            final reconCard = SectionCard(
              title: tr.reconciliation,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(ratio * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          tr.storesSynced(synced, active),
                          style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600),
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
            if (c.maxWidth < 620) return Column(children: [hourlyCard, const SizedBox(height: 16), reconCard]);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: hourlyCard),
                const SizedBox(width: 16),
                Expanded(child: reconCard),
              ],
            );
          },
        ),
      ],
    );
  }
}
