import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../viewmodels/employees_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/app_table.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/mini_stat_tile.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

class EmployeesView extends StatelessWidget {
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<EmployeesViewModel>();
    final query = context.select<HomeViewModel, String>((h) => h.query);
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    return AsyncContent(
      hasData: vm.hasData,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) {
        final list = vm.filtered(query);
        return PageBody(
          title: tr.navEmployees,
          subtitle: tr.employeesSubtitle,
          children: [
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                columns: c.maxWidth >= 620 ? 3 : 1,
                children: [
                  MiniStatTile(label: tr.navEmployees, value: '${vm.employees.length}', icon: Icons.groups_outlined),
                  MiniStatTile(
                    label: tr.onShiftNow,
                    value: '${vm.onShiftCount}',
                    icon: Icons.schedule,
                    iconColor: AppColors.green,
                  ),
                  MiniStatTile(
                    label: tr.monthlyPayroll,
                    value: cur.format(vm.monthlyPayroll),
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: tr.staffDirectory,
              child: AppTable(
                key: const Key('employees-table'),
                columns: [tr.name, tr.role, tr.store, tr.shift, tr.status],
                empty: tr.noEmployees,
                rows: [
                  for (final e in list)
                    [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.orangeSoft,
                            child: Text(
                              initials(e.name),
                              style: const TextStyle(fontSize: 11, color: AppColors.orange),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(e.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text(e.role),
                      Text(e.storeName),
                      Text(e.shift),
                      StatusBadge(
                        e.isOnShift ? tr.onShift : tr.offShift,
                        tone: e.isOnShift ? BadgeTone.positive : BadgeTone.neutral,
                        dot: true,
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
