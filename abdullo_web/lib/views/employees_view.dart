import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/employee_model.dart';
import '../viewmodels/dashboard_view_model.dart';
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
import 'employee_form_dialog.dart';
import '../core/motion/app_dialog.dart';

/// Employees — /api/employees (CRUD) + /api/reports/employees.
class EmployeesView extends StatelessWidget {
  const EmployeesView({super.key});

  Future<void> _delete(BuildContext context, EmployeeModel e) async {
    final tr = context.l10n;
    final ok = await showAppDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.deleteEmployeeTitle),
        content: Text(tr.deleteEmployeeBody(e.fullName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr.cancel)),
          FilledButton(
            key: const Key('confirm-delete-employee'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.delete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final dashboard = context.read<DashboardViewModel>();
    final error = await context.read<EmployeesViewModel>().delete(e.id);
    if (error == null) dashboard.load();
    if (context.mounted) showResult(context, error, success: tr.employeeDeleted(e.fullName));
  }

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
        final report = vm.report;
        return PageBody(
          title: tr.navEmployees,
          subtitle: tr.employeesSubtitle,
          actions: [
            FilledButton.icon(
              key: const Key('add-employee'),
              onPressed: () => EmployeeFormDialog.show(context),
              icon: const Icon(Icons.person_add_alt, size: 18),
              label: Text(tr.addEmployee),
            ),
          ],
          children: [
            LayoutBuilder(
              builder: (context, c) => CardGrid(
                columns: c.maxWidth >= 900 ? 4 : (c.maxWidth >= 620 ? 2 : 1),
                children: [
                  MiniStatTile(
                    label: tr.navEmployees,
                    value: '${report?.totalEmployees ?? vm.employees.length}',
                    icon: Icons.groups_outlined,
                  ),
                  MiniStatTile(
                    label: tr.active,
                    value: '${report?.activeEmployees ?? vm.activeCount}',
                    icon: Icons.verified_outlined,
                    iconColor: AppColors.green,
                  ),
                  MiniStatTile(
                    label: tr.monthlyPayroll,
                    value: cur.format(report?.monthlySalaryTotal ?? vm.monthlyPayroll),
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.orange,
                  ),
                  MiniStatTile(
                    label: tr.averageSalary,
                    value: cur.format(report?.averageMonthlySalary ?? 0),
                    icon: Icons.equalizer,
                  ),
                ],
              ),
            ),
            if ((report?.hiredThisMonth ?? 0) > 0) ...[
              const SizedBox(height: 10),
              StatusBadge(tr.hiredThisMonth(report!.hiredThisMonth), tone: BadgeTone.info),
            ],
            const SizedBox(height: 16),
            SectionCard(
              title: tr.staffDirectory,
              child: AppTable(
                key: const Key('employees-table'),
                columns: [tr.name, tr.role, tr.store, tr.monthlySalary, tr.hiredAt, tr.status, ''],
                numeric: const {3},
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
                              initials(e.fullName),
                              style: TextStyle(fontSize: 11, color: AppColors.accentText),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (e.phone != null)
                                Text(e.phone!, style: TextStyle(fontSize: 11, color: AppColors.muted)),
                            ],
                          ),
                        ],
                      ),
                      Text(e.position),
                      Text(e.storeName),
                      Text(cur.format(e.monthlySalary)),
                      Text('${formatDate(e.hiredAt)} · ${tr.tenure(e.monthsWorked)}'),
                      StatusBadge(
                        e.isActive ? tr.active : tr.inactive,
                        tone: e.isActive ? BadgeTone.positive : BadgeTone.neutral,
                        dot: true,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            key: Key('edit-employee-${e.id}'),
                            tooltip: tr.edit,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => EmployeeFormDialog.show(context, employee: e),
                            icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.muted),
                          ),
                          IconButton(
                            key: Key('delete-employee-${e.id}'),
                            tooltip: tr.delete,
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _delete(context, e),
                            icon: Icon(Icons.delete_outline, size: 18, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                ],
              ),
            ),
            if (report != null && report.byPosition.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: tr.byPosition,
                child: AppTable(
                  columns: [tr.position, tr.colEmployees, tr.active, tr.monthlyPayroll],
                  numeric: const {1, 2, 3},
                  rows: [
                    for (final p in report.byPosition)
                      [
                        Text(p.position, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${p.employees}'),
                        Text('${p.active}'),
                        Text(cur.format(p.salaryTotal)),
                      ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
