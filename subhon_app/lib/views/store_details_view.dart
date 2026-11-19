import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../models/employee_status.dart';
import '../models/store_status.dart';
import '../models/target_period.dart';
import '../services/activity_service.dart';
import '../services/employee_service.dart';
import '../services/reports_service.dart';
import '../services/sales_service.dart';
import '../services/store_service.dart';
import '../services/target_service.dart';
import '../viewmodels/store_details_view_model.dart';
import '../widgets/active_status_badge.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_card.dart';
import '../widgets/app_feedback.dart';
import '../widgets/async_state_view.dart';
import '../widgets/figure_card.dart';
import '../widgets/record_tile.dart';
import '../widgets/sales_target_card.dart';
import '../widgets/section_header.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_row.dart';
import 'activity_view.dart';
import 'store_form_view.dart';

/// A store: its details, latest sales (`GET /api/sales/store/{id}`) and
/// employees (`GET /api/employees/store/{id}`). Edit or delete it.
/// Pops `true` when the store changed.
class StoreDetailsView extends StatelessWidget {
  const StoreDetailsView({required this.storeId, super.key});

  final String storeId;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => StoreDetailsViewModel(
      context.read<StoreService>(),
      context.read<SalesService>(),
      context.read<EmployeeService>(),
      context.read<ActivityService>(),
      context.read<TargetService>(),
      context.read<ReportsService>(),
      storeId,
    )..load(),
    child: const _StoreDetails(),
  );
}

class _StoreDetails extends StatefulWidget {
  const _StoreDetails();

  @override
  State<_StoreDetails> createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<_StoreDetails> {
  bool _changed = false;

  Future<void> _edit(StoreDetailsViewModel vm) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => StoreFormView(initial: vm.store)),
    );
    if (saved ?? false) {
      _changed = true;
      await vm.load();
    }
  }

  Future<void> _delete(StoreDetailsViewModel vm) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.storeDeleteTitle,
      message: l10n.storeDeleteMessage,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await vm.delete();
      feedback.showSuccess(l10n.storeDeleted);
      navigator.pop(true);
    } on ApiException catch (e) {
      feedback.showError(errorText(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final vm = context.watch<StoreDetailsViewModel>();
    final store = vm.store;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(store?.name ?? l10n.navStores),
          actions: [
            if (store != null) ...[
              IconButton(
                tooltip: l10n.commonEdit,
                onPressed: () => _edit(vm),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: l10n.commonDelete,
                onPressed: () => _delete(vm),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ],
        ),
        body: RefreshIndicator(
          onRefresh: vm.load,
          child: AsyncStateView(
            isLoading: vm.isLoading,
            error: vm.error,
            hasData: vm.hasData,
            onRetry: vm.load,
            builder: (context) {
              final sales = vm.sales;
              final staff = vm.employees;
              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.sm,
                  AppSpacing.screen,
                  AppSpacing.xxxl,
                ),
                children: [
                  SettingsCard(
                    children: [
                      SettingsRow(
                        icon: Icons.storefront_outlined,
                        title: store!.name,
                        trailing: ActiveStatusBadge(
                          active: store.status == StoreStatus.active,
                        ),
                      ),
                      if (store.phone != null)
                        SettingsRow(
                          icon: Icons.phone_outlined,
                          title: l10n.fieldPhone,
                          value: store.phone,
                        ),
                      if (store.statusNote != null)
                        SettingsRow(
                          icon: Icons.info_outline_rounded,
                          title: l10n.fieldStatusNote,
                          value: store.statusNote,
                        ),
                      if (store.address != null)
                        SettingsRow(
                          icon: Icons.place_outlined,
                          title: l10n.fieldAddress,
                          value: store.address,
                        ),
                      if (store.city != null || store.region != null)
                        SettingsRow(
                          icon: Icons.location_city_outlined,
                          title: l10n.fieldCity,
                          value: [?store.city, ?store.region].join(', '),
                        ),
                      if (store.type != null)
                        SettingsRow(
                          icon: Icons.category_outlined,
                          title: l10n.fieldStoreType,
                          value: store.type,
                        ),
                      if (store.counters != null)
                        SettingsRow(
                          icon: Icons.point_of_sale_outlined,
                          title: l10n.fieldCounters,
                          value: '${store.counters}',
                        ),
                      if (store.openingHours != null)
                        SettingsRow(
                          icon: Icons.schedule_rounded,
                          title: l10n.fieldOpeningHours,
                          value: store.openingHours,
                        ),
                      if (store.description != null)
                        SettingsRow(
                          icon: Icons.notes_rounded,
                          title: l10n.fieldDescription,
                          value: store.description,
                        ),
                    ],
                  ),
                  if (vm.goals case final goals?) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SectionHeader(title: l10n.storeTargets),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SalesTargetCard(
                              period: TargetPeriod.week,
                              sales: goals.week,
                              target: goals.weekTarget,
                              hint: l10n.targetSheetHintStore,
                              onSave: (amount) =>
                                  vm.setTarget(TargetPeriod.week, amount),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: SalesTargetCard(
                              period: TargetPeriod.month,
                              sales: goals.month,
                              target: goals.monthTarget,
                              hint: l10n.targetSheetHintStore,
                              onSave: (amount) =>
                                  vm.setTarget(TargetPeriod.month, amount),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  FigureCard(
                    label: l10n.salesTotal,
                    value: context.money(sales?.totalAmount ?? 0),
                    valueColor: p.success,
                    caption: l10n.salesCount(sales?.total ?? 0),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: l10n.storeLatestSales),
                  if (sales == null || sales.items.isEmpty)
                    AppCard(
                      child: Text(
                        l10n.homeNoSales,
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
                          for (final sale in sales.items)
                            RecordTile(
                              icon: Icons.point_of_sale_rounded,
                              iconColor: p.success,
                              iconBackground: p.successLight,
                              title: context.formatDate(sale.saleDate),
                              subtitle: sale.description,
                              value: context.money(sale.amount, signed: true),
                              valueColor: p.success,
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: l10n.navEmployees),
                  if (staff == null || staff.items.isEmpty)
                    AppCard(
                      child: Text(
                        l10n.storeNoEmployees,
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
                          for (final e in staff.items)
                            RecordTile(
                              icon: Icons.person_outline_rounded,
                              iconColor: p.primary,
                              iconBackground: p.primaryLight,
                              title: e.fullName,
                              subtitle: e.position,
                              value: context.money(e.monthlySalary),
                              badge: ActiveStatusBadge(
                                active: e.status == EmployeeStatus.active,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (vm.log case final log? when log.items.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SectionHeader(
                      title: l10n.activityLogTitle,
                      actionLabel: log.hasMore ? l10n.homeShowAll : null,
                      onAction: log.hasMore
                          ? () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ActivityView(
                                  storeId: vm.storeId,
                                  title: l10n.activityLogTitle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Column(
                        children: [
                          for (final a in log.items) ActivityTile(activity: a),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
