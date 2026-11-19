import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/employee_status.dart';
import '../services/employee_service.dart';
import '../services/reports_service.dart';
import '../viewmodels/employees_view_model.dart';
import '../widgets/active_status_badge.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_view.dart';
import '../widgets/async_state_view.dart';
import '../widgets/figure_card.dart';
import '../widgets/load_more_button.dart';
import '../widgets/record_tile.dart';
import '../widgets/search_field.dart';
import 'employee_form_view.dart';

/// Employees with the totals of `GET /api/reports/employees`; search,
/// page by page; tap to edit.
class EmployeesView extends StatelessWidget {
  const EmployeesView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => EmployeesViewModel(
      context.read<EmployeeService>(),
      context.read<ReportsService>(),
    )..load(),
    child: const _Employees(),
  );
}

class _Employees extends StatelessWidget {
  const _Employees();

  Future<void> _open(BuildContext context, Widget screen) async {
    final vm = context.read<EmployeesViewModel>();
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (changed ?? false) await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<EmployeesViewModel>();
    final report = vm.report;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navEmployees),
        actions: [
          IconButton(
            tooltip: l10n.actionNewEmployee,
            onPressed: () => _open(context, const EmployeeFormView()),
            icon: const Icon(Icons.person_add_alt_1_outlined),
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
          isEmpty: vm.items.isEmpty && vm.search.isEmpty,
          empty: AppEmptyView(
            icon: Icons.badge_outlined,
            title: l10n.employeesEmptyTitle,
            message: l10n.employeesEmptyMessage,
            actionLabel: l10n.actionNewEmployee,
            onAction: () => _open(context, const EmployeeFormView()),
          ),
          builder: (context) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              AppSpacing.xxxl,
            ),
            children: [
              if (report != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FigureCard(
                        label: l10n.employeesActive,
                        value: '${report.activeEmployees}',
                        caption: l10n.homeOfTotal(report.totalEmployees),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FigureCard(
                        label: l10n.employeesSalaryFund,
                        value: context.money(report.monthlySalaryTotal),
                        caption: l10n.employeesAverage(
                          context.money(report.averageMonthlySalary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              SearchField(
                initialValue: vm.search,
                hint: l10n.employeesSearch,
                clearTooltip: l10n.commonClear,
                onChanged: vm.searchAsTyped,
              ),
              const SizedBox(height: AppSpacing.md),
              if (vm.items.isEmpty)
                AppCard(
                  child: Text(
                    l10n.commonNothingFound,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    children: [
                      for (final e in vm.items)
                        RecordTile(
                          icon: Icons.person_outline_rounded,
                          iconColor: p.primary,
                          iconBackground: p.primaryLight,
                          title: e.fullName,
                          subtitle: '${e.position} · ${e.storeName}',
                          value: context.money(e.monthlySalary),
                          badge: ActiveStatusBadge(
                            active: e.status == EmployeeStatus.active,
                          ),
                          onTap: () =>
                              _open(context, EmployeeFormView(initial: e)),
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
          ),
        ),
      ),
    );
  }
}
