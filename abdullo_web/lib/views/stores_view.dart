import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../models/store_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/icon_box.dart';
import '../widgets/page_body.dart';
import '../widgets/status_badge.dart';

class StoresView extends StatelessWidget {
  const StoresView({super.key});

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
        final list = vm.filtered(query);
        return PageBody(
          title: 'Stores',
          subtitle:
              '${vm.activeCount} of ${vm.stores.length} stores active · ${cur.format(vm.totalSales)} this month',
          children: [
            if (list.isEmpty) Text('No stores match "$query"'),
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                key: const Key('stores-grid'),
                columns: c.maxWidth >= 1000 ? 3 : (c.maxWidth >= 620 ? 2 : 1),
                spacing: 16,
                children: [for (final s in list) _StoreCard(store: s, share: vm.shareOf(s), currency: cur)],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store, required this.share, required this.currency});

  final StoreModel store;
  final double share;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconBox(
                  Icons.storefront_outlined,
                  color: AppColors.navy,
                  background: AppColors.surfaceSoft,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        '${store.type} • ${store.area}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  store.isActive ? 'Active' : 'Closed',
                  tone: store.isActive ? BadgeTone.positive : BadgeTone.neutral,
                  dot: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 10,
              children: [
                stat('Monthly sales', currency.format(store.monthlySales)),
                stat('Staff', '${store.staffCount}'),
                stat('Counters', '${store.counters}'),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: share,
                minHeight: 5,
                backgroundColor: AppColors.border,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manager: ${store.manager}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ),
                Text(
                  '${(share * 100).toStringAsFixed(1)}% share',
                  style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
