import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/store_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/app_table.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/dropdown_chip.dart';
import '../widgets/icon_box.dart';
import '../widgets/kpi_card.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import 'store_detail_sheet.dart';
import 'store_form_dialog.dart';

/// "Store Management" — /api/stores + sales reports.
class StoresView extends StatelessWidget {
  const StoresView({super.key});

  static void _export(BuildContext context, StoresViewModel vm, List<StoreModel> stores) {
    final csv = StringBuffer('Name,Address,Phone,Status,Today TJS,Month TJS,Staff\n');
    for (final s in stores) {
      final st = vm.statsOf(s);
      csv.writeln(
        '"${s.name}","${s.address ?? ''}","${s.phone ?? ''}",${s.isActive ? 'ACTIVE' : 'INACTIVE'},'
        '${st.today.toStringAsFixed(2)},${st.month.toStringAsFixed(2)},${st.staff}',
      );
    }
    Clipboard.setData(ClipboardData(text: csv.toString()));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.rowsCopied(stores.length))));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<StoresViewModel>();
    final query = context.select<HomeViewModel, String>((h) => h.query);
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    return AsyncContent(
      hasData: vm.hasData,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) {
        final list = vm.visible(query);
        return PageBody(
          eyebrow: [tr.storesEyebrow1, tr.storesEyebrow2],
          title: tr.storesTitle,
          subtitle: tr.storesSubtitle,
          actions: [
            OutlinedButton.icon(
              key: const Key('export-stores'),
              onPressed: () => _export(context, vm, list),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: Text(tr.exportDirectory),
            ),
            FilledButton.icon(
              key: const Key('add-store'),
              onPressed: () => StoreFormDialog.show(context),
              icon: const Icon(Icons.add, size: 18),
              label: Text(tr.addNewStore),
            ),
          ],
          children: [
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                columns: c.maxWidth >= 900 ? 4 : 2,
                children: [
                  KpiCard(
                    title: tr.networkScope,
                    value: tr.nLocations(vm.stores.length),
                    icon: Icons.apartment_outlined,
                    badge: tr.opRatio((vm.operatingRatio * 100).round()),
                    caption: tr.activeInactive(vm.activeCount, vm.inactiveCount),
                  ),
                  KpiCard(
                    title: tr.fleetVelocity,
                    value: cur.amount(vm.todayTotal),
                    unit: cur.code,
                    icon: Icons.payments_outlined,
                    badge: vm.todayChange == null ? null : formatPercent(vm.todayChange!),
                    badgeTone: (vm.todayChange ?? 0) >= 0 ? BadgeTone.positive : BadgeTone.negative,
                    caption: tr.allBranchesToday,
                  ),
                  KpiCard(
                    title: tr.totalMonthlyRevenue,
                    value: cur.amount(vm.monthTotal),
                    unit: cur.code,
                    icon: Icons.insights_outlined,
                    badge: vm.monthChange == null ? null : formatPercent(vm.monthChange!),
                    badgeTone: (vm.monthChange ?? 0) >= 0 ? BadgeTone.positive : BadgeTone.negative,
                    caption: tr.vsLastMonth,
                  ),
                  KpiCard(
                    title: tr.allocatedWorkforce,
                    value: tr.nActive(vm.workforce),
                    icon: Icons.badge_outlined,
                    badge: tr.acrossBranches(vm.staffedBranches),
                    badgeTone: BadgeTone.info,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _FilterBar(vm: vm),
            const SizedBox(height: 16),
            if (list.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(child: Text(tr.noStoresMatch)),
                ),
              )
            else if (vm.gridView)
              LayoutBuilder(
                builder: (context, c) => CardGrid(
                  key: const Key('stores-grid'),
                  columns: c.maxWidth >= 1000 ? 3 : (c.maxWidth >= 620 ? 2 : 1),
                  spacing: 16,
                  children: [for (final s in list) _StoreCard(store: s, stats: vm.statsOf(s), currency: cur)],
                ),
              )
            else
              Card(
                key: const Key('stores-list'),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AppTable(
                    columns: [
                      tr.store,
                      tr.address,
                      tr.status,
                      tr.kpiTodaySales,
                      tr.monthlyVolume,
                      tr.staff,
                      tr.phone,
                      '',
                    ],
                    numeric: const {3, 4, 5},
                    rows: [
                      for (final s in list)
                        [
                          Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(s.address ?? '—'),
                          _StatusBadge(store: s),
                          Text(cur.format(vm.statsOf(s).today)),
                          Text(cur.format(vm.statsOf(s).month), style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${vm.statsOf(s).staff}'),
                          Text(s.phone ?? '—'),
                          _StoreActions(store: s),
                        ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final share = _ShareCard(vm: vm, currency: cur);
                final recent = _RecentCard(stores: vm.recentlyUpdated);
                if (c.maxWidth < 1000) return Column(children: [share, const SizedBox(height: 16), recent]);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: share),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: recent),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.vm});

  final StoresViewModel vm;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final statusLabel = switch (vm.statusFilter) {
      StoreStatusFilter.all => tr.allStatusCounts(vm.activeCount, vm.inactiveCount),
      StoreStatusFilter.active => tr.activeOnly(vm.activeCount),
      StoreStatusFilter.inactive => tr.inactiveOnly(vm.inactiveCount),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, c) {
            final search = TextField(
              key: const Key('store-search'),
              onChanged: vm.setQuery,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: tr.searchStores,
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            );
            final controls = Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownChip<StoreStatusFilter>(
                  key: const Key('store-status-filter'),
                  label: statusLabel,
                  value: vm.statusFilter,
                  onSelected: vm.setStatusFilter,
                  items: [
                    (StoreStatusFilter.all, tr.allStatus),
                    (StoreStatusFilter.active, tr.active),
                    (StoreStatusFilter.inactive, tr.inactive),
                  ],
                ),
                DropdownChip<StoreSort>(
                  key: const Key('store-sort'),
                  label: tr.sortBy(tr.storeSort(vm.sort)),
                  value: vm.sort,
                  onSelected: vm.setSort,
                  items: [for (final s in StoreSort.values) (s, tr.storeSort(s))],
                ),
                _ViewToggle(grid: vm.gridView, onChanged: vm.setGridView),
              ],
            );
            if (c.maxWidth < 760) return Column(children: [search, const SizedBox(height: 10), controls]);
            return Row(
              children: [
                Expanded(child: search),
                const SizedBox(width: 12),
                controls,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.grid, required this.onChanged});

  final bool grid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    Widget btn(bool value, IconData icon, String tip) => IconButton(
      key: Key(value ? 'grid-view' : 'list-view'),
      tooltip: tip,
      visualDensity: VisualDensity.compact,
      isSelected: grid == value,
      style: IconButton.styleFrom(
        backgroundColor: grid == value ? AppColors.navy : AppColors.surfaceSoft,
        foregroundColor: grid == value ? Colors.white : AppColors.muted,
      ),
      onPressed: () => onChanged(value),
      icon: Icon(icon, size: 18),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [btn(true, Icons.grid_view, tr.grid), const SizedBox(width: 4), btn(false, Icons.view_list, tr.list)],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) => StatusBadge(
    context.l10n.storeStatus(store),
    tone: store.isActive ? BadgeTone.positive : BadgeTone.neutral,
    dot: true,
  );
}

class _StoreActions extends StatelessWidget {
  const _StoreActions({required this.store, this.showAnalytics = false});

  final StoreModel store;
  final bool showAnalytics;

  Future<void> _delete(BuildContext context) async {
    final tr = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.deleteStoreTitle),
        content: Text(tr.deleteStoreBody(store.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr.cancel)),
          FilledButton(
            key: const Key('confirm-delete'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final dashboard = context.read<DashboardViewModel>();
    final error = await context.read<StoresViewModel>().delete(store.id);
    if (error == null) dashboard.load();
    if (context.mounted) showResult(context, error, success: tr.storeDeleted(store.name));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return Row(
      mainAxisSize: showAnalytics ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (showAnalytics) ...[
          TextButton(
            key: Key('analytics-${store.id}'),
            style: TextButton.styleFrom(
              foregroundColor: store.isActive ? AppColors.orange : AppColors.muted,
              padding: EdgeInsets.zero,
            ),
            onPressed: () => StoreDetailSheet.show(context, store.id),
            child: Text(tr.viewAnalytics, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
        ],
        IconButton(
          key: Key('edit-${store.id}'),
          tooltip: tr.edit,
          visualDensity: VisualDensity.compact,
          onPressed: () => StoreFormDialog.show(context, store: store),
          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.muted),
        ),
        IconButton(
          key: Key('delete-${store.id}'),
          tooltip: tr.delete,
          visualDensity: VisualDensity.compact,
          onPressed: () => _delete(context),
          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.stats, required this.currency});

  final StoreModel store;
  final StoreStats stats;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final s = store;
    final first = stats.rank == 1 && stats.month > 0;
    Widget figure(String label, String value, String sub, Color subColor) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: subColor),
        ),
      ],
    );
    Widget info(IconData icon, String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.muted),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return Card(
      key: Key('store-card-${s.id}'),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: first
            ? const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.orange, width: 3)),
              )
            : null,
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      s.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.25),
                    ),
                  ),
                  if (first) const Icon(Icons.workspace_premium_outlined, size: 18, color: AppColors.orange),
                  const SizedBox(width: 6),
                  _StatusBadge(store: s),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.muted),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    s.address ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(
                    child: figure(
                      tr.kpiTodaySales,
                      currency.format(stats.today),
                      s.isActive ? tr.active : tr.offline,
                      s.isActive ? AppColors.green : AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: figure(
                      tr.monthlyVolume,
                      currency.format(stats.month),
                      first
                          ? tr.topEarner
                          : stats.monthChange == null
                          ? tr.shareValue((stats.share * 100).toStringAsFixed(0))
                          : '${formatPercent(stats.monthChange!)} · ${tr.vsLastMonth}',
                      first ? AppColors.orange : AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                children: [
                  info(Icons.phone_outlined, tr.phone, s.phone ?? '—'),
                  info(Icons.groups_outlined, tr.staffHeadcount, tr.nEmployees(stats.staff)),
                  if ((s.description ?? '').isNotEmpty) info(Icons.notes_outlined, tr.description, s.description!),
                ],
              ),
            ),
            const Divider(height: 20),
            _StoreActions(store: s, showAnalytics: true),
          ],
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.vm, required this.currency});

  final StoresViewModel vm;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final rows = vm.shares.take(6).toList();
    return SectionCard(
      title: tr.salesShare,
      subtitle: tr.storeComparisonTitle,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(6)),
        child: Text(
          '${tr.endpoint}:\n${ApiConstants.reportStoreComparison}',
          style: const TextStyle(fontSize: 10.5, color: AppColors.navy),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rows.isEmpty) Text(tr.noSalesThisMonth),
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rows[i].storeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${currency.format(rows[i].totalAmount)} (${rows[i].sharePercent.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rows[i].sharePercent / 100,
                      minHeight: 7,
                      backgroundColor: AppColors.border,
                      color: i == 0
                          ? AppColors.orange
                          : i == 1
                          ? AppColors.navy
                          : AppColors.barGray,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            tr.registersSynced(vm.activeCount),
            style: const TextStyle(fontSize: 11.5, color: AppColors.green, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.stores});

  final List<StoreModel> stores;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return SectionCard(
      title: tr.recentlyUpdated,
      trailing: const Icon(Icons.history, color: AppColors.navy),
      child: Column(
        children: [
          if (stores.isEmpty) Text(tr.noOperations),
          for (final s in stores)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  IconBox(
                    Icons.storefront_outlined,
                    size: 28,
                    color: s.isActive ? AppColors.green : AppColors.muted,
                    background: s.isActive ? AppColors.greenSoft : AppColors.surfaceSoft,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(
                          tr.updatedOn(s.updatedAt == null ? '—' : formatTimeAgo(s.updatedAt!)),
                          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
                        ),
                      ],
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
