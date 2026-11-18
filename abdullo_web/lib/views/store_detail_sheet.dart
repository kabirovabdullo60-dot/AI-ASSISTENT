import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/store_model.dart';
import '../services/employee_service.dart';
import '../services/sales_service.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/store_detail_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/async_content.dart';
import '../widgets/icon_box.dart';

/// Side panel with one store's analytics (slides in from the right; full screen on a phone).
class StoreDetailSheet extends StatelessWidget {
  const StoreDetailSheet({super.key, required this.storeId});

  final String storeId;

  static Future<void> show(BuildContext context, String storeId) => showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.close,
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => StoreDetailSheet(storeId: storeId),
    transitionBuilder: (_, anim, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final width = math.min(MediaQuery.sizeOf(context).width, 520.0);
    final stores = context.watch<StoresViewModel>();
    final store = stores.byId(storeId);
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        key: const Key('store-detail'),
        color: AppColors.background,
        child: SizedBox(
          width: width,
          height: double.infinity,
          child: store == null
              ? Center(child: Text(tr.storeNotFound))
              : ChangeNotifierProvider(
                  create: (_) =>
                      StoreDetailViewModel(context.read<SalesService>(), context.read<EmployeeService>(), storeId)
                        ..load(),
                  child: _Body(store: store, stats: stores.statsOf(store)),
                ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.store, required this.stats});

  final StoreModel store;
  final StoreStats stats;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<StoreDetailViewModel>();
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    return SafeArea(
      child: Column(
        children: [
          Container(
            color: AppColors.blueSoft,
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      Text(store.address ?? '—', style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('close-detail'),
                  tooltip: tr.close,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncContent(
              hasData: vm.last7Days != null,
              error: vm.error,
              onRetry: vm.load,
              builder: (_) => _Content(store: store, stats: stats, vm: vm, currency: cur),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.store, required this.stats, required this.vm, required this.currency});

  final StoreModel store;
  final StoreStats stats;
  final StoreDetailViewModel vm;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final days = vm.last7Days!;
    final maxV = days.isEmpty ? 0.0 : days.map((d) => d.revenue).reduce(math.max);

    Widget tile(String label, double value, double? change, {bool accent = false}) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                currency.format(value),
                style: TextStyle(fontWeight: FontWeight.w800, color: accent ? AppColors.orange : AppColors.ink),
              ),
            ),
            if (change != null)
              Text(
                formatPercent(change),
                style: TextStyle(fontSize: 11, color: change >= 0 ? AppColors.green : AppColors.red),
              ),
          ],
        ),
      ),
    );
    Widget param(String label, String value, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
    BoxDecoration box() => BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            tile(tr.dailySales, stats.today, null),
            const SizedBox(width: 8),
            tile(tr.kpiWeeklySales, stats.week, null),
            const SizedBox(width: 8),
            tile(tr.monthlyTotal, stats.month, stats.monthChange, accent: true),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: box(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(tr.velocity7, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                  Text(
                    tr.avgPerDay(currency.format(vm.average)),
                    style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < days.length; i++)
                      Expanded(
                        child: Tooltip(
                          message: '${formatDay(days[i].date)}: ${currency.format(days[i].revenue)}',
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: maxV == 0 ? 2 : math.max(2, 90 * days[i].revenue / maxV),
                            decoration: BoxDecoration(
                              color: i == days.length - 1 ? AppColors.orange : AppColors.blueSoft,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(tr.sixDaysAgo, style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  const Spacer(),
                  Text(tr.todayCurrent, style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: box(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr.storeParams, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              param(tr.phoneLine, store.phone ?? '—'),
              param(tr.staffAllocation, tr.activeCrew(vm.staff.where((e) => e.isActive).length)),
              param(tr.apiSync, 'GET ${ApiConstants.store(store.id)}', color: AppColors.green),
              param(tr.statusLabel, tr.storeStatus(store)),
              if (store.createdAt != null) param(tr.createdLabel, formatDate(store.createdAt!)),
              if ((store.description ?? '').isNotEmpty) param(tr.description, store.description!),
            ],
          ),
        ),
        if (vm.staff.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(tr.staffInStore, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in vm.staff)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: CircleAvatar(child: Text(initials(e.fullName), style: const TextStyle(fontSize: 9))),
                  label: Text('${e.fullName} · ${e.position}'),
                ),
            ],
          ),
        ],
        const SizedBox(height: 14),
        Text(tr.recentPos, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        if (vm.recent.isEmpty) Text(tr.noSalesYet),
        for (final s in vm.recent)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.blueSoft, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                IconBox(
                  Icons.receipt_long_outlined,
                  size: 28,
                  color: AppColors.orange,
                  background: AppColors.orangeSoft,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatRelativeDay(s.saleDate),
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      if ((s.description ?? '').isNotEmpty)
                        Text(s.description!, style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
                Text(
                  '+${currency.format(s.amount)}',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.green),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
