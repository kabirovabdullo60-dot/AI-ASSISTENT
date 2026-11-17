import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/responsive/breakpoints.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../widgets/card_grid.dart';
import '../widgets/error_retry.dart';
import '../widgets/insight_tile.dart';
import '../widgets/kpi_card.dart';
import '../widgets/sales_bar_chart.dart';
import '../widgets/section_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final data = vm.data;

    if (data == null) {
      if (vm.error != null) return ErrorRetry(message: vm.error!, onRetry: vm.load);
      return const Center(child: CircularProgressIndicator());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final type = Breakpoints.of(constraints.maxWidth);
        final isDesktop = type == ScreenType.desktop;
        final padding = type == ScreenType.mobile ? 16.0 : 24.0;

        final chart = SectionCard(
          title: 'Sales — last 6 months',
          child: SalesBarChart(points: data.sales),
        );
        final insights = SectionCard(
          title: 'AI insights',
          child: Column(children: [for (final i in data.insights) InsightTile(insight: i)]),
        );

        return ListView(
          key: const Key('dashboard-view'),
          padding: EdgeInsets.all(padding),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: vm.isLoading ? null : vm.load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CardGrid(
              columns: isDesktop ? 4 : 2,
              children: [for (final k in data.kpis) KpiCard(kpi: k)],
            ),
            const SizedBox(height: 16),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: chart),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: insights),
                ],
              )
            else ...[
              chart,
              const SizedBox(height: 16),
              insights,
            ],
          ],
        );
      },
    );
  }
}
