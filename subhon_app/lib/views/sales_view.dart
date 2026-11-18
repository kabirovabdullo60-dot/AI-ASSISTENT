import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/sale_model.dart';
import '../viewmodels/sales_view_model.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/app_picker_field.dart';
import '../widgets/async_state_view.dart';
import '../widgets/figure_card.dart';
import '../widgets/load_more_button.dart';
import '../widgets/options_sheet.dart';
import '../widgets/record_tile.dart';
import 'sale_form_view.dart';

/// Sales: filter by store and dates, the total of the filter, newest first,
/// page by page. Tap a sale to edit or delete it.
class SalesView extends StatelessWidget {
  const SalesView({super.key});

  Future<void> _openForm(BuildContext context, {SaleModel? sale}) async {
    final vm = context.read<SalesViewModel>();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SaleFormView(initial: sale)),
    );
    if (saved ?? false) await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<SalesViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSales),
        actions: [
          IconButton(
            tooltip: l10n.actionNewSale,
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: AsyncStateView(
          isLoading: vm.isLoading,
          error: vm.error,
          hasData: vm.hasData,
          onRetry: vm.load,
          isEmpty: vm.items.isEmpty && !vm.isFiltered,
          empty: AppEmptyView(
            icon: Icons.point_of_sale_outlined,
            title: l10n.salesEmptyTitle,
            message: l10n.salesEmptyMessage,
            actionLabel: l10n.actionNewSale,
            onAction: () => _openForm(context),
          ),
          builder: (context) => _SalesList(
            vm: vm,
            onOpen: (sale) => _openForm(context, sale: sale),
          ),
        ),
      ),
    );
  }
}

class _SalesList extends StatelessWidget {
  const _SalesList({required this.vm, required this.onOpen});

  final SalesViewModel vm;
  final ValueChanged<SaleModel> onOpen;

  Future<void> _pickStore(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showOptionsSheet<String>(
      context,
      title: l10n.fieldStore,
      selected: vm.storeId ?? '',
      options: [
        ('', l10n.salesAllStores),
        for (final s in vm.stores) (s.id, s.name),
      ],
    );
    if (picked == null) return;
    await vm.setFilter(
      storeId: picked.isEmpty ? null : picked,
      startDate: vm.startDate,
      endDate: vm.endDate,
    );
  }

  Future<void> _pickDates(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: vm.startDate == null || vm.endDate == null
          ? null
          : DateTimeRange(start: vm.startDate!, end: vm.endDate!),
    );
    if (range == null) return;
    await vm.setFilter(
      storeId: vm.storeId,
      startDate: range.start,
      endDate: range.end,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final storeName = vm.storeId == null
        ? l10n.salesAllStores
        : vm.stores
                  .where((s) => s.id == vm.storeId)
                  .map((s) => s.name)
                  .firstOrNull ??
              l10n.salesAllStores;
    final dates = vm.startDate == null || vm.endDate == null
        ? l10n.salesAllDates
        : '${context.formatShortDate(vm.startDate!)} – '
              '${context.formatShortDate(vm.endDate!)}';
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.xxxl,
      ),
      children: [
        AppPickerField(
          label: l10n.fieldStore,
          value: storeName,
          leading: const Icon(Icons.storefront_outlined),
          onTap: () => _pickStore(context),
        ),
        const SizedBox(height: AppSpacing.md),
        AppPickerField(
          label: l10n.fieldPeriod,
          value: dates,
          leading: const Icon(Icons.date_range_outlined),
          onTap: () => _pickDates(context),
        ),
        if (vm.isFiltered)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: vm.clearFilter,
              child: Text(l10n.salesClearFilter),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        FigureCard(
          label: l10n.salesTotal,
          value: context.money(vm.totalAmount ?? 0),
          valueColor: p.success,
          caption: l10n.salesCount(vm.total),
        ),
        const SizedBox(height: AppSpacing.md),
        if (vm.items.isEmpty)
          AppCard(
            child: Text(
              l10n.salesNothingFound,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                for (final sale in vm.items)
                  RecordTile(
                    icon: Icons.point_of_sale_rounded,
                    iconColor: p.success,
                    iconBackground: p.successLight,
                    title: sale.storeName,
                    subtitle: [
                      context.formatDate(sale.saleDate),
                      if (sale.description != null) sale.description!,
                    ].join(' · '),
                    value: context.money(sale.amount, signed: true),
                    valueColor: p.success,
                    onTap: () => onOpen(sale),
                  ),
              ],
            ),
          ),
        if (vm.hasMore)
          LoadMoreButton(
            label: l10n.commonShowMore,
            isLoading: vm.isLoadingMore,
            onPressed: vm.loadMore,
          ),
      ],
    );
  }
}
