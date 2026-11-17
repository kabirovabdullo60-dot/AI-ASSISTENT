import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/sales_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/app_table.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/mini_stat_tile.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import 'record_sale_dialog.dart';

class SalesView extends StatelessWidget {
  const SalesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SalesViewModel>();
    final query = context.select<HomeViewModel, String>((h) => h.query);
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    return AsyncContent(
      hasData: vm.hasData,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) {
        final list = vm.filtered(query);
        return PageBody(
          title: 'Sales',
          subtitle: 'Every receipt from all registers',
          actions: [
            FilledButton.icon(
              key: const Key('record-sale'),
              onPressed: () => RecordSaleDialog.show(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Record Sale'),
            ),
          ],
          children: [
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                columns: c.maxWidth >= 620 ? 3 : 1,
                children: [
                  MiniStatTile(
                    label: 'Recorded sales',
                    value: cur.format(vm.total),
                    icon: Icons.payments_outlined,
                  ),
                  MiniStatTile(
                    label: 'Receipts',
                    value: '${vm.sales.length}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  MiniStatTile(
                    label: 'Average ticket',
                    value: cur.format(vm.averageTicket),
                    icon: Icons.sell_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Recent receipts',
              child: AppTable(
                key: const Key('sales-table'),
                columns: const ['Receipt', 'Store', 'Method', 'Register', 'Time', 'Amount'],
                numeric: const {5},
                empty: 'No sales found',
                rows: [
                  for (final s in list)
                    [
                      Text(s.receipt, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      Text(s.storeName),
                      StatusBadge(s.method.label, tone: BadgeTone.info),
                      Text(s.register),
                      Text(
                        '${formatTime(s.time)} · ${formatTimeAgo(s.time)}',
                        style: const TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      Text(
                        cur.format(s.amount),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.green),
                      ),
                    ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
