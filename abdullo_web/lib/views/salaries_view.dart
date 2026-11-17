import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../models/payroll_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/payroll_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/app_table.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/mini_stat_tile.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

class SalariesView extends StatelessWidget {
  const SalariesView({super.key});

  Future<void> _pay(BuildContext context, PayrollModel p) async {
    final messenger = ScaffoldMessenger.of(context);
    final dashboard = context.read<DashboardViewModel>();
    final ok = await context.read<PayrollViewModel>().markPaid(p.id);
    if (ok) dashboard.load();
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? 'Salary paid to ${p.employeeName}' : 'Payment failed. Try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PayrollViewModel>();
    final query = context.select<HomeViewModel, String>((h) => h.query);
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    return AsyncContent(
      hasData: vm.hasData,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) {
        final list = vm.filtered(query);
        return PageBody(
          title: 'Salaries',
          subtitle: 'Payroll for the current cycle',
          children: [
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                columns: c.maxWidth >= 620 ? 3 : 1,
                children: [
                  MiniStatTile(
                    label: 'Unpaid',
                    value: cur.format(vm.pendingTotal),
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.orange,
                  ),
                  MiniStatTile(
                    label: 'Waiting',
                    value: '${vm.pendingCount} people',
                    icon: Icons.hourglass_bottom,
                  ),
                  MiniStatTile(
                    label: 'Paid this cycle',
                    value: cur.format(vm.paidTotal),
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Payroll',
              child: AppTable(
                key: const Key('payroll-table'),
                columns: const ['Employee', 'Store', 'Period', 'Amount', 'Status'],
                numeric: const {3},
                empty: 'No salaries found',
                rows: [
                  for (final p in list)
                    [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.employeeName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(p.role, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                      Text(p.storeName),
                      Text(p.period),
                      Text(cur.format(p.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                      p.isPaid
                          ? const StatusBadge('Paid', tone: BadgeTone.positive, icon: Icons.check)
                          : FilledButton.tonal(
                              key: Key('pay-${p.id}'),
                              onPressed: vm.payingId == null ? () => _pay(context, p) : null,
                              style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                              child: vm.payingId == p.id
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Pay'),
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
