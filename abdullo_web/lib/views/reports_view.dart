import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../viewmodels/assistant_view_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/app_table.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/mini_stat_tile.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  void _analyze(BuildContext context) {
    context.read<HomeViewModel>().select(AppSection.assistant);
    context.read<AssistantViewModel>().send('Analyze my sales report');
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardViewModel>();
    final stores = context.watch<StoresViewModel>();
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    return AsyncContent(
      hasData: dashboard.overview != null && stores.hasData,
      error: dashboard.error ?? stores.error,
      onRetry: () {
        dashboard.load();
        stores.load();
      },
      builder: (_) {
        final o = dashboard.overview!;
        final ranked = stores.ranked;
        return PageBody(
          title: 'Reports',
          subtitle: 'Monthly performance by store',
          actions: [
            FilledButton.icon(
              key: const Key('analyze-report'),
              onPressed: () => _analyze(context),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Analyze with AI'),
            ),
          ],
          children: [
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                columns: c.maxWidth >= 620 ? 3 : 1,
                children: [
                  MiniStatTile(
                    label: 'Monthly sales (${formatPercent(o.monthlyChange)})',
                    value: cur.format(o.monthlySales),
                    icon: Icons.insights_outlined,
                    iconColor: AppColors.green,
                  ),
                  MiniStatTile(label: 'Gross margin', value: '${o.grossMargin}%', icon: Icons.percent),
                  MiniStatTile(
                    label: 'Average per day',
                    value: cur.format(o.averageDaily),
                    icon: Icons.calendar_month_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Sales by store',
              child: AppTable(
                key: const Key('reports-table'),
                columns: const ['#', 'Store', 'Type', 'Monthly sales', 'Share'],
                numeric: const {3, 4},
                rows: [
                  for (var i = 0; i < ranked.length; i++)
                    [
                      Text('${i + 1}'),
                      Text(ranked[i].name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(ranked[i].type),
                      Text(cur.format(ranked[i].monthlySales)),
                      Text(
                        '${(stores.shareOf(ranked[i]) * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w600),
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
