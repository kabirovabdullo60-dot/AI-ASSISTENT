import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/constants/api_constants.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/activity_model.dart';
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

/// "Store Management" from the Figma.
class StoresView extends StatelessWidget {
  const StoresView({super.key});

  static void _export(BuildContext context, List<StoreModel> stores) {
    final csv = StringBuffer('Name,City,Address,Phone,Status,Today TJS,Monthly TJS,Staff\n');
    for (final s in stores) {
      csv.writeln(
        '"${s.name}","${s.city}","${s.address}","${s.phone}",${s.isActive ? 'Active' : 'Inactive'},'
        '${s.todaySales.round()},${s.monthlySales.round()},${s.staffCount}',
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
        double weighted(double Function(StoreModel) value, double Function(StoreModel) change) {
          final total = vm.stores.fold<double>(0, (s, e) => s + value(e));
          return total == 0 ? 0 : vm.stores.fold<double>(0, (s, e) => s + value(e) * change(e)) / total;
        }

        final todayChange = weighted((s) => s.todaySales, (s) => s.todayChange);
        final monthChange = weighted((s) => s.monthlySales, (s) => s.monthlyChange);

        return PageBody(
          eyebrow: [tr.storesEyebrow1, tr.storesEyebrow2],
          title: tr.storesTitle,
          subtitle: tr.storesSubtitle,
          actions: [
            OutlinedButton.icon(
              key: const Key('export-stores'),
              onPressed: () => _export(context, list),
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
                    badge: formatPercent(todayChange),
                    badgeIcon: Icons.trending_up,
                    caption: tr.allBranchesToday,
                  ),
                  KpiCard(
                    title: tr.totalMonthlyRevenue,
                    value: cur.amount(vm.totalSales),
                    unit: cur.code,
                    icon: Icons.insights_outlined,
                    badge: formatPercent(monthChange),
                    badgeIcon: Icons.trending_up,
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
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text(tr.noStoresMatch)),
                ),
              )
            else if (vm.gridView)
              LayoutBuilder(
                builder: (context, c) => CardGrid(
                  key: const Key('stores-grid'),
                  columns: c.maxWidth >= 1000 ? 3 : (c.maxWidth >= 620 ? 2 : 1),
                  spacing: 16,
                  children: [for (final s in list) _StoreCard(store: s, rank: vm.rankOf(s), currency: cur)],
                ),
              )
            else
              Card(
                key: const Key('stores-list'),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AppTable(
                    columns: [tr.store, tr.city, tr.status, tr.kpiTodaySales, tr.monthlyVolume, tr.staff, tr.phone, ''],
                    numeric: const {3, 4, 5},
                    rows: [
                      for (final s in list)
                        [
                          Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(s.city),
                          _StatusBadge(store: s),
                          Text(cur.format(s.todaySales)),
                          Text(cur.format(s.monthlySales), style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('${s.staffCount}'),
                          Text(s.phone),
                          _StoreActions(store: s),
                        ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, c) {
                final regional = _RegionalCard(vm: vm, currency: cur);
                final log = _OperationsLogCard(log: vm.operationsLog);
                if (c.maxWidth < 1000) return Column(children: [regional, const SizedBox(height: 16), log]);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: regional),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: log),
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
                prefixIcon: Icon(Icons.search, size: 18),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
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
    final messenger = ScaffoldMessenger.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final done = await context.read<StoresViewModel>().delete(store.id);
    if (done) dashboard.load();
    messenger.showSnackBar(SnackBar(content: Text(done ? tr.storeDeleted(store.name) : tr.deleteFailed)));
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
            child: Text(tr.viewAnalytics, style: TextStyle(fontWeight: FontWeight.w600)),
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
  const _StoreCard({required this.store, required this.rank, required this.currency});

  final StoreModel store;
  final int rank;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final s = store;
    final first = rank == 1 && s.isActive;
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
                    s.fullAddress,
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
                      "Today's Sales",
                      currency.format(s.todaySales),
                      s.isActive ? tr.vsYest(formatPercent(s.todayChange)) : tr.offline,
                      s.isActive ? AppColors.green : AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: figure(
                      tr.monthlyVolume,
                      currency.format(s.monthlySales),
                      rank == 1 && s.isActive ? tr.topEarner : s.note,
                      AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                children: [
                  info(Icons.phone_outlined, tr.phone, s.phone),
                  info(
                    Icons.groups_outlined,
                    tr.staffHeadcount,
                    s.staffCount == 0 && !s.isActive ? tr.reassigned : tr.nEmployees(s.staffCount),
                  ),
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

class _RegionalCard extends StatelessWidget {
  const _RegionalCard({required this.vm, required this.currency});

  final StoresViewModel vm;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final regions = vm.regions;
    return SectionCard(
      title: tr.regionalTitle,
      subtitle: tr.regionalSubtitle(regions.map((r) => r.region).join(', ')),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(6)),
        child: Text(
          '${tr.endpoint}:\n${ApiConstants.stores}',
          style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.navy),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < regions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${regions[i].region} (${tr.branchesCount(regions[i].stores)}${regions[i].inactive > 0 ? ' · ${tr.nInactive(regions[i].inactive)}' : ''})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${currency.format(regions[i].sales)} (${(regions[i].share * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: regions[i].share,
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
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 6,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                  children: [
                    TextSpan(
                      text: '● ',
                      style: TextStyle(color: AppColors.orange),
                    ),
                    TextSpan(text: '${tr.capitalOutlets}   '),
                    TextSpan(
                      text: '● ',
                      style: TextStyle(color: AppColors.navy),
                    ),
                    TextSpan(text: tr.regionalTerritory),
                  ],
                ),
              ),
              Text(
                tr.registersSynced(vm.activeCount),
                style: const TextStyle(fontSize: 11.5, color: AppColors.green, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OperationsLogCard extends StatelessWidget {
  const _OperationsLogCard({required this.log});

  final List<ActivityModel> log;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return SectionCard(
      title: tr.opsLog,
      trailing: const Icon(Icons.history, color: AppColors.navy),
      child: Column(
        children: [
          if (log.isEmpty) Text(tr.noOperations),
          for (final a in log)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBox(
                    switch (a.type) {
                      ActivityType.sale => Icons.inventory_2_outlined,
                      ActivityType.staff => Icons.construction_outlined,
                      _ => Icons.storefront_outlined,
                    },
                    size: 28,
                    color: a.type == ActivityType.sale ? AppColors.orange : AppColors.green,
                    background: a.type == ActivityType.sale ? AppColors.orangeSoft : AppColors.greenSoft,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.highlight, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Text(a.reference, style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 16),
          TextButton(
            onPressed: () => context.read<HomeViewModel>().select(AppSection.dashboard),
            style: TextButton.styleFrom(foregroundColor: AppColors.orange),
            child: Text(tr.viewAuditTrail, style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
