import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/responsive/breakpoints.dart';
import '../core/utils/format.dart';
import '../models/kpi_model.dart';
import '../viewmodels/assistant_view_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/card_grid.dart';
import '../widgets/error_retry.dart';
import '../widgets/kpi_card.dart';
import '../widgets/section_card.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  static const assistantSection = 1;

  void _analyze(BuildContext context) {
    context.read<HomeViewModel>().select(assistantSection);
    context.read<AssistantViewModel>().send('Analyze my sales report');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    if (vm.data == null) {
      if (vm.error != null) return ErrorRetry(message: vm.error!, onRetry: vm.load);
      return const Center(child: CircularProgressIndicator());
    }

    final best = vm.bestMonth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final type = Breakpoints.of(constraints.maxWidth);
        final padding = type == ScreenType.mobile ? 16.0 : 24.0;

        return ListView(
          key: const Key('reports-view'),
          padding: EdgeInsets.all(padding),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Text(
                  'Sales report',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                FilledButton.icon(
                  key: const Key('analyze-report'),
                  onPressed: () => _analyze(context),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Analyze with AI'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CardGrid(
              columns: type == ScreenType.mobile ? 1 : 3,
              children: [
                KpiCard(
                  kpi: KpiModel(title: 'Total (6 months)', value: vm.totalSales, unit: 'TJS'),
                ),
                KpiCard(
                  kpi: KpiModel(title: 'Monthly average', value: vm.averageSales, unit: 'TJS'),
                ),
                KpiCard(
                  kpi: KpiModel(
                    title: best == null ? 'Best month' : 'Best month — ${best.label}',
                    value: best?.value ?? 0,
                    unit: 'TJS',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'By month',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth - padding * 2 - 32),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Month')),
                      DataColumn(label: Text('Revenue (TJS)'), numeric: true),
                      DataColumn(label: Text('Change'), numeric: true),
                    ],
                    rows: [
                      for (var i = 0; i < vm.sales.length; i++)
                        DataRow(
                          cells: [
                            DataCell(Text(vm.sales[i].label)),
                            DataCell(Text(formatAmount(vm.sales[i].value))),
                            DataCell(_ChangeText(vm.changeAt(i))),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChangeText extends StatelessWidget {
  const _ChangeText(this.change);

  final double? change;

  @override
  Widget build(BuildContext context) {
    final value = change;
    if (value == null) return const Text('—');
    return Text(
      formatPercent(value),
      style: TextStyle(color: value >= 0 ? Colors.green.shade600 : Theme.of(context).colorScheme.error),
    );
  }
}
