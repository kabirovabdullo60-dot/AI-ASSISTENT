import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/constants/api_constants.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/activity_model.dart';
import '../models/overview_model.dart';
import '../models/store_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/stores_view_model.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/icon_box.dart';
import '../widgets/kpi_card.dart';
import '../widgets/mini_stat_tile.dart';
import '../widgets/page_body.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import 'record_sale_dialog.dart';

/// "Business Overview" — the Figma Executive Business Dashboard.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    return AsyncContent(
      hasData: vm.overview != null,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) => _DashboardContent(vm: vm, overview: vm.overview!),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.vm, required this.overview});

  final DashboardViewModel vm;
  final OverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);
    final o = overview;
    final quarter = (DateTime.now().month - 1) ~/ 3 + 1;

    final kpis = [
      KpiCard(
        title: tr.kpiTotalStores,
        value: tr.nActive(o.activeStores),
        icon: Icons.storefront_outlined,
        badge: o.newStoresThisQuarter > 0 ? tr.quarterNew(o.newStoresThisQuarter, quarter) : null,
        caption: tr.ofRegistered(o.totalStores),
      ),
      KpiCard(
        title: tr.kpiTotalStaff,
        value: tr.nStaff(o.totalStaff),
        icon: Icons.badge_outlined,
        badge: tr.nActive(o.staffOnShift),
        badgeTone: BadgeTone.info,
        caption: tr.onShiftToday,
      ),
      _moneyKpi(tr.kpiTodaySales, o.todaySales, o.todayChange, tr.vsYesterday, Icons.today_outlined, cur),
      _moneyKpi(
        tr.kpiWeeklySales,
        o.weeklySales,
        o.weeklyChange,
        tr.target(formatCompact(cur.fromTjs(o.weeklyTarget))),
        Icons.date_range_outlined,
        cur,
      ),
      _moneyKpi(tr.kpiMonthlySales, o.monthlySales, o.monthlyChange, tr.mom, Icons.insights_outlined, cur),
      KpiCard(
        title: tr.kpiUnpaidSalaries,
        value: cur.amount(o.unpaidSalaries),
        unit: cur.code,
        icon: Icons.account_balance_wallet_outlined,
        badge: tr.nPending(o.pendingPayrolls),
        badgeTone: BadgeTone.warning,
        badgeDot: true,
        caption: tr.cycle(o.payrollCycle),
        highlight: true,
      ),
    ];

    return PageBody(
      title: tr.businessOverview,
      badge: StatusBadge(tr.liveAudit, tone: BadgeTone.info),
      subtitle: tr.overviewSubtitle,
      actions: [
        const _DateChip(),
        _CurrencyToggle(selected: cur),
        FilledButton.icon(
          key: const Key('record-sale'),
          onPressed: () => RecordSaleDialog.show(context),
          icon: const Icon(Icons.add, size: 18),
          label: Text(tr.recordSale),
        ),
      ],
      children: [
        LayoutBuilder(
          builder: (context, c) =>
              CardGrid(columns: c.maxWidth >= 1100 ? 6 : (c.maxWidth >= 620 ? 3 : 2), children: kpis),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final chart = _RevenueCard(vm: vm, overview: o, currency: cur);
            const stores = _TopStoresCard();
            if (c.maxWidth < 1100) return Column(children: [chart, const SizedBox(height: 16), stores]);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: chart),
                const SizedBox(width: 16),
                const Expanded(flex: 3, child: stores),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _ActivityCard(vm: vm, currency: cur),
      ],
    );
  }

  KpiCard _moneyKpi(String title, double tjs, double change, String caption, IconData icon, Currency cur) => KpiCard(
    title: title,
    value: cur.amount(tjs),
    unit: cur.code,
    icon: icon,
    badge: formatPercent(change),
    badgeTone: change >= 0 ? BadgeTone.positive : BadgeTone.negative,
    badgeIcon: change >= 0 ? Icons.trending_up : Icons.trending_down,
    caption: caption,
  );
}

class _DateChip extends StatelessWidget {
  const _DateChip();

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.orange),
          const SizedBox(width: 6),
          Text(
            tr.todayDate(formatDate(DateTime.now())),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  const _CurrencyToggle({required this.selected});

  final Currency selected;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Currency>(
      key: const Key('currency-toggle'),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        selectedBackgroundColor: AppColors.navy,
        selectedForegroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      segments: [for (final c in Currency.values) ButtonSegment(value: c, label: Text(c.label))],
      selected: {selected},
      onSelectionChanged: (s) => context.read<SettingsViewModel>().setCurrency(s.first),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.vm, required this.overview, required this.currency});

  final DashboardViewModel vm;
  final OverviewModel overview;
  final Currency currency;

  List<String> _labels(bool narrow, AppLocalizations tr) {
    final points = vm.chartPoints;
    final n = points.length;
    final peak = vm.peakIndex;
    if (vm.range == ChartRange.weekly) {
      return [for (var i = 0; i < n; i++) i == n - 1 ? tr.today : formatWeekday(points[i].date)];
    }
    return [
      for (var i = 0; i < n; i++)
        if (i == n - 1)
          tr.today
        else if (i == peak)
          narrow ? formatDay(points[i].date) : '${formatDay(points[i].date)} (${tr.peakShort})'
        else if (i % 5 == 0 && (i - peak).abs() > 3 && n - 1 - i > 3)
          formatDay(points[i].date)
        else
          '',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final points = vm.chartPoints;
    final peak = vm.peakIndex;
    final peakPoint = peak >= 0 ? points[peak] : null;
    final o = overview;

    return SectionCard(
      title: tr.revenueTitle,
      subtitle: tr.revenueSubtitle,
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 520;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SegmentedButton<ChartRange>(
                    key: Key('chart-range'),
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    segments: [
                      ButtonSegment(value: ChartRange.weekly, label: Text(tr.weekly)),
                      ButtonSegment(value: ChartRange.monthly, label: Text(tr.monthly)),
                    ],
                    selected: {vm.range},
                    onSelectionChanged: (s) => vm.setRange(s.first),
                  ),
                  if (peakPoint != null)
                    StatusBadge(
                      tr.peakLabel(
                        '${formatWeekday(peakPoint.date)}, ${formatDay(peakPoint.date)}',
                        currency.format(peakPoint.revenue),
                      ),
                      tone: BadgeTone.warning,
                      icon: Icons.bolt,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(8)),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        children: [
                          const TextSpan(
                            text: '● ',
                            style: TextStyle(color: AppColors.green),
                          ),
                          TextSpan(text: tr.averageDaily),
                          TextSpan(
                            text: currency.format(o.averageDaily),
                            style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: '   ·   ${tr.totalVolume}'),
                          TextSpan(
                            text: tr.txns(formatAmount(o.totalTransactions.toDouble())),
                            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      tr.autoReconciliation('${o.reconciliationRate}'),
                      style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RevenueChart(
                points: points,
                peakIndex: peak,
                xLabels: _labels(narrow, tr),
                peakLabel: peakPoint == null ? '' : currency.amount(peakPoint.revenue),
                tooltipLines: (i) => [
                  '${formatWeekday(points[i].date)}, ${formatDay(points[i].date)}',
                  tr.chartRevenue(currency.format(points[i].revenue)),
                  tr.chartCashflow(currency.format(points[i].cashflow)),
                ],
                height: narrow ? 220 : 270,
              ),
              const SizedBox(height: 14),
              CardGrid(
                columns: c.maxWidth >= 560 ? 3 : 1,
                children: [
                  MiniStatTile(
                    label: tr.grossMargin,
                    value: '${o.grossMargin}%',
                    icon: Icons.percent,
                    iconColor: AppColors.green,
                  ),
                  MiniStatTile(label: tr.onlineSplit, value: tr.cardShare('${o.onlineShare}'), icon: Icons.qr_code_2),
                  MiniStatTile(
                    label: tr.cashVaults,
                    value: currency.format(o.cashInVaults),
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.orange,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopStoresCard extends StatelessWidget {
  const _TopStoresCard();

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<StoresViewModel>();
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);
    final top = vm.top(4);
    final maxShare = top.isEmpty ? 1.0 : vm.shareOf(top.first);

    return SectionCard(
      title: tr.topStores,
      badge: StatusBadge(tr.ranked, tone: BadgeTone.warning),
      subtitle: tr.rankedSubtitle,
      trailing: const Icon(Icons.leaderboard_outlined, color: AppColors.navy),
      child: !vm.hasData
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              children: [
                for (var i = 0; i < top.length; i++)
                  _StoreRankTile(
                    rank: i + 1,
                    store: top[i],
                    share: vm.shareOf(top[i]),
                    barValue: maxShare == 0 ? 0 : vm.shareOf(top[i]) / maxShare,
                    currency: cur,
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    key: const Key('view-all-stores'),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.blueSoft,
                      foregroundColor: AppColors.navy,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => context.read<HomeViewModel>().select(AppSection.stores),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            tr.viewAllStores(vm.stores.length),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StoreRankTile extends StatelessWidget {
  const _StoreRankTile({
    required this.rank,
    required this.store,
    required this.share,
    required this.barValue,
    required this.currency,
  });

  final int rank;
  final StoreModel store;
  final double share;
  final double barValue;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final first = rank == 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: first ? AppColors.orange : AppColors.surfaceSoft,
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: first ? Colors.white : AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tr.countersType(store.type, store.counters),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currency.format(store.monthlySales),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tr.shareValue('${(share * 100).round()}'),
                    style: const TextStyle(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barValue,
              minHeight: 4,
              backgroundColor: AppColors.border,
              color: first ? AppColors.orange : AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.vm, required this.currency});

  final DashboardViewModel vm;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final query = context.select<HomeViewModel, String>((h) => h.query);
    final items = vm.activity(query);

    return SectionCard(
      title: tr.recentActivity,
      badge: StatusBadge(tr.liveFeed),
      subtitle: tr.activitySubtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(ApiConstants.useMock ? tr.demoFeed : tr.syncActive, tone: BadgeTone.positive, dot: true),
          PopupMenuButton<ActivityType?>(
            key: const Key('activity-filter'),
            tooltip: tr.filter,
            icon: Icon(Icons.filter_list, color: vm.activityFilter == null ? AppColors.muted : AppColors.orange),
            onSelected: vm.setActivityFilter,
            itemBuilder: (_) => [
              PopupMenuItem(value: null, child: Text(tr.allActivity)),
              for (final t in ActivityType.values) PopupMenuItem(value: t, child: Text(tr.activityType(t))),
            ],
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxWidth < 560;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (items.isEmpty) Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text(tr.noActivity)),
              for (final a in items) _ActivityRow(activity: a, currency: currency, compact: compact),
              const Divider(height: 24),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 16,
                runSpacing: 6,
                children: [
                  Text(
                    tr.connectedTo(ApiConstants.mainEndpoints.join(', ')),
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.muted),
                  ),
                  Text(
                    ApiConstants.useMock ? tr.demoBackend : ApiConstants.baseUrl,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity, required this.currency, required this.compact});

  final ActivityModel activity;
  final Currency currency;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final (IconData icon, Color color, Color bg) = switch (a.type) {
      ActivityType.sale => (Icons.receipt_long_outlined, AppColors.green, AppColors.greenSoft),
      ActivityType.payroll => (Icons.payments_outlined, AppColors.orange, AppColors.orangeSoft),
      ActivityType.audit => (Icons.verified_outlined, AppColors.blue, AppColors.blueSoft),
      ActivityType.staff => (Icons.person_add_alt, AppColors.purple, AppColors.purpleSoft),
    };
    final amount = a.amount;
    final time = Text(formatTimeAgo(a.time), style: const TextStyle(fontSize: 11, color: AppColors.muted));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon, color: color, background: bg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 13, color: AppColors.ink, height: 1.35),
                    children: [
                      TextSpan(text: '${a.text} '),
                      TextSpan(
                        text: a.highlight,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (a.detail.isNotEmpty) TextSpan(text: a.detail),
                      if (amount != null)
                        TextSpan(
                          text: ': ${amount >= 0 ? '+' : '-'}${currency.format(amount.abs())}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: amount >= 0 ? AppColors.green : AppColors.red,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (a.reference.isNotEmpty)
                      Text(
                        a.reference,
                        style: const TextStyle(fontSize: 11, color: AppColors.muted, fontFamily: 'monospace'),
                      ),
                    if (a.tag.isNotEmpty) StatusBadge(a.tag, tone: BadgeTone.info),
                    if (compact) time,
                  ],
                ),
              ],
            ),
          ),
          if (!compact) ...[const SizedBox(width: 12), time],
        ],
      ),
    );
  }
}
