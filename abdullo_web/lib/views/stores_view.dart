import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Directory of ${stores.length} stores copied as CSV — paste it into Excel')));
  }

  @override
  Widget build(BuildContext context) {
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
          eyebrow: const ['ENTERPRISE FLEET', 'STORE DIRECTORY'],
          title: 'Store Management',
          subtitle: 'Manage multi-branch retail locations, track revenue and branch health across regional networks.',
          actions: [
            OutlinedButton.icon(
              key: const Key('export-stores'),
              onPressed: () => _export(context, list),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Export Directory'),
            ),
            FilledButton.icon(
              key: const Key('add-store'),
              onPressed: () => StoreFormDialog.show(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add New Store'),
            ),
          ],
          children: [
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                columns: c.maxWidth >= 900 ? 4 : 2,
                children: [
                  KpiCard(
                    title: 'Network Scope',
                    value: '${vm.stores.length} Locations',
                    icon: Icons.apartment_outlined,
                    badge: '${(vm.operatingRatio * 100).round()}% Op. Ratio',
                    caption: '${vm.activeCount} active · ${vm.inactiveCount} inactive',
                  ),
                  KpiCard(
                    title: "Today's Fleet Velocity",
                    value: cur.amount(vm.todayTotal),
                    unit: cur.code,
                    icon: Icons.payments_outlined,
                    badge: formatPercent(todayChange),
                    badgeIcon: Icons.trending_up,
                    caption: 'all branches today',
                  ),
                  KpiCard(
                    title: 'Total Monthly Revenue',
                    value: cur.amount(vm.totalSales),
                    unit: cur.code,
                    icon: Icons.insights_outlined,
                    badge: formatPercent(monthChange),
                    badgeIcon: Icons.trending_up,
                    caption: 'vs last month',
                  ),
                  KpiCard(
                    title: 'Allocated Workforce',
                    value: '${vm.workforce} Active',
                    icon: Icons.badge_outlined,
                    badge: 'Across ${vm.staffedBranches} branches',
                    badgeTone: BadgeTone.info,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _FilterBar(vm: vm),
            const SizedBox(height: 16),
            if (list.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No stores match the filters')),
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
                    columns: const ['Store', 'City', 'Status', "Today's Sales", 'Monthly Volume', 'Staff', 'Phone', ''],
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
    final statusLabel = switch (vm.statusFilter) {
      StoreStatusFilter.all => 'All Status (${vm.activeCount} Active, ${vm.inactiveCount} Inactive)',
      StoreStatusFilter.active => 'Active only (${vm.activeCount})',
      StoreStatusFilter.inactive => 'Inactive only (${vm.inactiveCount})',
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
              decoration: const InputDecoration(
                hintText: 'Search stores by name, city, phone…',
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
                    (StoreStatusFilter.all, 'All Status'),
                    (StoreStatusFilter.active, 'Active'),
                    (StoreStatusFilter.inactive, 'Inactive'),
                  ],
                ),
                DropdownChip<StoreSort>(
                  key: const Key('store-sort'),
                  label: 'Sort by: ${vm.sort.label}',
                  value: vm.sort,
                  onSelected: vm.setSort,
                  items: [for (final s in StoreSort.values) (s, s.label)],
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
      children: [btn(true, Icons.grid_view, 'Grid'), const SizedBox(width: 4), btn(false, Icons.view_list, 'List')],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) =>
      StatusBadge(store.statusLabel, tone: store.isActive ? BadgeTone.positive : BadgeTone.neutral, dot: true);
}

class _StoreActions extends StatelessWidget {
  const _StoreActions({required this.store, this.showAnalytics = false});

  final StoreModel store;
  final bool showAnalytics;

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete store?'),
        content: Text('"${store.name}" will be removed from the directory. Its past sales stay in reports.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            key: const Key('confirm-delete'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final done = await context.read<StoresViewModel>().delete(store.id);
    if (done) dashboard.load();
    messenger.showSnackBar(SnackBar(content: Text(done ? '${store.name} deleted' : 'Could not delete the store')));
  }

  @override
  Widget build(BuildContext context) {
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
            child: const Text('View Analytics →', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
        ],
        IconButton(
          key: Key('edit-${store.id}'),
          tooltip: 'Edit',
          visualDensity: VisualDensity.compact,
          onPressed: () => StoreFormDialog.show(context, store: store),
          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.muted),
        ),
        IconButton(
          key: Key('delete-${store.id}'),
          tooltip: 'Delete',
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
                      s.isActive ? '${formatPercent(s.todayChange)} vs yest.' : 'Offline',
                      s.isActive ? AppColors.green : AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: figure(
                      'Monthly Volume',
                      currency.format(s.monthlySales),
                      rank == 1 && s.isActive ? 'Top Earner (#1)' : s.note,
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
                  info(Icons.phone_outlined, 'Phone', s.phone),
                  info(
                    Icons.groups_outlined,
                    'Staff Headcount',
                    s.staffCount == 0 && !s.isActive ? '0 (reassigned)' : '${s.staffCount} employees',
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
    final regions = vm.regions;
    return SectionCard(
      title: 'Regional Sales Distribution',
      subtitle: 'Live breakdown across ${regions.map((r) => r.region).join(', ')} territories',
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(6)),
        child: Text(
          'Endpoint:\n${ApiConstants.stores}',
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
                          '${regions[i].region} (${regions[i].stores} '
                          '${regions[i].stores == 1 ? 'Branch' : 'Branches'}'
                          '${regions[i].inactive > 0 ? ' · ${regions[i].inactive} inactive' : ''})',
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
              const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                  children: [
                    TextSpan(
                      text: '● ',
                      style: TextStyle(color: AppColors.orange),
                    ),
                    TextSpan(text: 'Capital outlets   '),
                    TextSpan(
                      text: '● ',
                      style: TextStyle(color: AppColors.navy),
                    ),
                    TextSpan(text: 'Regional territory'),
                  ],
                ),
              ),
              Text(
                '✓ All ${vm.activeCount} active registers synced',
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
    return SectionCard(
      title: 'Store Operations Log',
      trailing: const Icon(Icons.history, color: AppColors.navy),
      child: Column(
        children: [
          if (log.isEmpty) const Text('No operations yet'),
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
            child: const Text('View Full Audit Trail →', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
