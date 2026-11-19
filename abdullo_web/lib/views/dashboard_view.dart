import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/l10n/l10n.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../core/utils/format.dart';
import '../models/activity_model.dart';
import '../models/dashboard_model.dart';
import '../models/sales_report_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/async_content.dart';
import '../widgets/card_grid.dart';
import '../widgets/icon_box.dart';
import '../widgets/kpi_card.dart';
import '../widgets/mini_stat_tile.dart';
import '../widgets/page_body.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import '../core/motion/motion.dart';
import '../widgets/motion/pressable.dart';
import '../widgets/motion/photo_slideshow.dart';
import '../widgets/motion/number_ticker.dart';
import '../widgets/motion/ai_orb.dart';
import '../viewmodels/assistant_view_model.dart';
import '../core/theme/app_theme.dart';
import '../widgets/motion/shimmer_sweep.dart';
import 'record_sale_dialog.dart';
import 'targets_dialog.dart';

/// "Business Overview" — GET /api/reports/dashboard + sales reports.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    return AsyncContent(
      hasData: vm.dashboard != null,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) => _DashboardContent(vm: vm, d: vm.dashboard!),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  /// Whether the entrance already played in this session.
  static bool _entered = false;

  const _DashboardContent({required this.vm, required this.d});

  final DashboardViewModel vm;
  final DashboardModel d;

  KpiCard _money(String title, double tjs, double? change, String caption, IconData icon, Currency cur) => KpiCard(
    title: title,
    value: cur.amount(tjs),
    number: tjs,
    format: cur.amount,
    unit: cur.code,
    icon: icon,
    badge: change == null ? null : formatPercent(change),
    badgeTone: (change ?? 0) >= 0 ? BadgeTone.positive : BadgeTone.negative,
    badgeIcon: (change ?? 0) >= 0 ? Icons.trending_up : Icons.trending_down,
    caption: caption,
  );

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    final kpis = [
      KpiCard(
        title: tr.kpiTotalStores,
        value: tr.nActive(d.activeStores),
        icon: Icons.storefront_outlined,
        caption: tr.ofRegistered(d.totalStores),
      ),
      KpiCard(
        title: tr.kpiTotalStaff,
        value: tr.nStaff(d.activeEmployees),
        icon: Icons.badge_outlined,
        badge: tr.nActive(d.activeEmployees),
        badgeTone: BadgeTone.info,
        caption: tr.ofTotal(d.totalEmployees),
      ),
      _money(
        tr.profitThisMonth,
        d.monthProfit,
        null,
        '${tr.navExpenses}: ${cur.format(d.monthExpenses)}',
        Icons.savings_outlined,
        cur,
      ),
      _money(
        tr.kpiWeeklySales,
        d.weekSales,
        vm.weekChange,
        tr.salesCount(d.weekSalesCount),
        Icons.date_range_outlined,
        cur,
      ),
      _money(
        tr.kpiMonthlySales,
        d.monthSales,
        vm.monthChange,
        tr.salesCount(d.monthSalesCount),
        Icons.insights_outlined,
        cur,
      ),
      KpiCard(
        title: tr.kpiUnpaidSalaries,
        value: cur.amount(d.remainingSalaryThisMonth),
        number: d.remainingSalaryThisMonth,
        format: cur.amount,
        unit: cur.code,
        icon: Icons.account_balance_wallet_outlined,
        badge: tr.cycle(formatMonth(d.today)),
        badgeTone: BadgeTone.warning,
        badgeDot: true,
        caption: tr.ofDue(cur.format(d.salaryDueThisMonth)),
        highlight: d.remainingSalaryThisMonth > 0,
      ),
    ];

    // The dashboard is opened many times a day: its entrance plays once per session only.
    final entrance = !_DashboardContent._entered && !Motion.reduced(context);
    _DashboardContent._entered = true;
    // KPI cards: non-uniform delays that shrink (60, 100, 130, 150, 165, 175 ms) read as one wave.
    const kpiDelays = [60, 110, 140, 160, 175, 185];
    Widget kpi(int i, Widget card) => entrance
        ? card
              .animate(delay: kpiDelays[i.clamp(0, 5)].ms)
              .fadeIn(duration: 420.ms, curve: Motion.easeOut)
              .moveY(begin: 8, end: 0, duration: 420.ms, curve: Motion.easeOut)
        : card;
    Widget support(Widget w) => entrance ? w.animate(delay: 190.ms).fadeIn(duration: 420.ms, curve: Motion.easeOut) : w;

    return PageBody(
      entrance: entrance,
      title: tr.businessOverview,
      subtitle: tr.overviewSubtitle,
      actions: [
        const _DateChip(),
        _CurrencyToggle(selected: cur),
      ],
      children: [
        // Bento top row: the hero (today's sales on a real photo) and the AI card.
        LayoutBuilder(
          builder: (context, c) {
            final hero = kpi(0, _HeroCard(d: d, change: vm.todayChange, currency: cur));
            final ai = kpi(1, const _AiCard());
            if (c.maxWidth < 900) return Column(children: [hero, const SizedBox(height: 16), ai]);
            return SizedBox(
              height: 252,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: hero),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: ai),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) => CardGrid(
            columns: c.maxWidth >= 1100 ? 6 : (c.maxWidth >= 620 ? 3 : 2),
            children: [
              // Cards arrive as one wave on the first visit, and lift under the mouse.
              for (var i = 0; i < kpis.length; i++) kpi(i, Pressable(child: kpis[i])),
            ],
          ),
        ),
        const SizedBox(height: 16),
        support(_GoalsCard(d: d, currency: cur)),
        const SizedBox(height: 16),
        support(
          LayoutBuilder(
            builder: (context, c) {
              final chart = _RevenueCard(vm: vm, d: d, currency: cur);
              final stores = _TopStoresCard(stores: vm.topStores, currency: cur);
              if (c.maxWidth < 1100) return Column(children: [chart, const SizedBox(height: 16), stores]);
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: chart),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: stores),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _ActivityCard(vm: vm, currency: cur),
      ],
    );
  }
}

/// Weekly / monthly sales targets (PUT /api/targets) and this month's profit (dashboard fields).
class _GoalsCard extends StatelessWidget {
  const _GoalsCard({required this.d, required this.currency});

  final DashboardModel d;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    Widget progress(Key key, String label, double done, double? target) {
      final ratio = target == null || target <= 0 ? 0.0 : done / target;
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(
            target == null
                ? tr.noTarget
                : '${currency.format(done)} / ${currency.format(target)} · ${(ratio * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            // The bar fills up from 0 when the dashboard opens or a target changes.
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio.clamp(0, 1).toDouble()),
              duration: Motion.reveal,
              curve: Motion.easeOut,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: AppColors.surfaceSoft,
                color: ratio >= 1 ? AppColors.green : AppColors.orange,
              ),
            ),
          ),
        ],
      );
    }

    final profit = Column(
      key: const Key('month-profit'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr.profitThisMonth, style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 4),
        Text(
          currency.format(d.monthProfit),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: d.monthProfit >= 0 ? AppColors.green : AppColors.red,
          ),
        ),
        Text(
          [
            '${tr.navExpenses}: ${currency.format(d.monthExpenses)}',
            if (d.monthMarginPercent != null) formatPercent(d.monthMarginPercent!),
          ].join(' · '),
          style: TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
      ],
    );

    final parts = [
      progress(const Key('week-target'), tr.weeklyTarget, d.weekSales, d.weekTarget),
      progress(const Key('month-target'), tr.monthlyTarget, d.monthSales, d.monthTarget),
      profit,
    ];

    return SectionCard(
      title: tr.goalsTitle,
      trailing: TextButton.icon(
        key: const Key('set-targets'),
        onPressed: () => TargetsDialog.show(context, d),
        icon: const Icon(Icons.flag_outlined, size: 18),
        label: Text(tr.setTargets),
      ),
      child: LayoutBuilder(
        builder: (context, c) => c.maxWidth < 700
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final p in parts) Padding(padding: const EdgeInsets.only(bottom: 14), child: p)],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < parts.length; i++) ...[
                    if (i > 0) const SizedBox(width: 24),
                    Expanded(child: parts[i]),
                  ],
                ],
              ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip();

  @override
  Widget build(BuildContext context) {
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
          Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.orange),
          const SizedBox(width: 6),
          Text(
            context.l10n.todayDate(formatDate(DateTime.now())),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
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
        textStyle: const TextStyle(fontFamily: 'Onest', fontSize: 12, fontWeight: FontWeight.w600),
      ),
      segments: [for (final c in Currency.values) ButtonSegment(value: c, label: Text(c.label))],
      selected: {selected},
      onSelectionChanged: (s) => context.read<SettingsViewModel>().setCurrency(s.first),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.vm, required this.d, required this.currency});

  final DashboardViewModel vm;
  final DashboardModel d;
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
        else if (i % 5 == 0 && (peak < 0 || (i - peak).abs() > 3) && n - 1 - i > 3)
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
    final month = vm.monthReport;

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
                    key: const Key('chart-range'),
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(fontFamily: 'Onest', fontSize: 12, fontWeight: FontWeight.w600),
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
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                        ),
                      ),
                      TextSpan(text: tr.averageDaily),
                      TextSpan(
                        text: currency.format(vm.averageDaily),
                        style: TextStyle(color: AppColors.green, fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: '   ·   ${tr.totalVolume}'),
                      TextSpan(
                        text: tr.salesCount(d.monthSalesCount),
                        style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
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
                  tr.chartSales(points[i].count),
                ],
                height: narrow ? 220 : 270,
              ),
              const SizedBox(height: 14),
              CardGrid(
                columns: c.maxWidth >= 560 ? 3 : 1,
                children: [
                  MiniStatTile(
                    label: tr.averageSale,
                    value: currency.format(month?.averageSaleAmount ?? 0),
                    icon: Icons.receipt_long_outlined,
                    iconColor: AppColors.green,
                  ),
                  MiniStatTile(
                    label: tr.salesThisMonth,
                    value: tr.salesCount(d.monthSalesCount),
                    icon: Icons.point_of_sale_outlined,
                  ),
                  MiniStatTile(
                    label: tr.unpaidAllMonths,
                    value: currency.format(d.remainingSalaryTotal),
                    icon: Icons.account_balance_wallet_outlined,
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
  const _TopStoresCard({required this.stores, required this.currency});

  final List<StoreSalesModel> stores;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final top = stores.take(4).toList();
    final maxShare = top.isEmpty ? 1.0 : top.first.sharePercent;

    return SectionCard(
      title: tr.topStores,
      badge: StatusBadge(tr.ranked, tone: BadgeTone.warning),
      subtitle: tr.rankedSubtitle,
      trailing: Icon(Icons.leaderboard_outlined, color: AppColors.ink),
      child: Column(
        children: [
          if (top.isEmpty) Padding(padding: const EdgeInsets.all(16), child: Text(tr.noSalesThisMonth)),
          for (var i = 0; i < top.length; i++)
            _StoreRankTile(
              rank: i + 1,
              store: top[i],
              barValue: maxShare == 0 ? 0 : top[i].sharePercent / maxShare,
              currency: currency,
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              key: const Key('view-all-stores'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.blueSoft,
                foregroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => context.read<HomeViewModel>().select(AppSection.stores),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr.viewAllStores(stores.length),
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
  const _StoreRankTile({required this.rank, required this.store, required this.barValue, required this.currency});

  final int rank;
  final StoreSalesModel store;
  final double barValue;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final first = rank == 1;
    final change = store.changePercent;
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
                    color: first ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.storeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tr.salesCount(store.salesCount)}${change == null ? '' : ' · ${formatPercent(change)}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currency.format(store.totalAmount),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tr.shareValue(store.sharePercent.toStringAsFixed(0)),
                    style: TextStyle(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w600),
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
      trailing: PopupMenuButton<ActivityType?>(
        key: const Key('activity-filter'),
        tooltip: tr.filter,
        icon: Icon(Icons.filter_list, color: vm.activityFilter == null ? AppColors.muted : AppColors.orange),
        onSelected: vm.setActivityFilter,
        itemBuilder: (_) => [
          PopupMenuItem(value: null, child: Text(tr.allActivity)),
          for (final t in ActivityType.values) PopupMenuItem(value: t, child: Text(tr.activityType(t))),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxWidth < 560;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (items.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(tr.noActivity)),
              for (final a in items) _ActivityRow(activity: a, currency: currency, compact: compact),
              const Divider(height: 24),
              Text(
                tr.connectedTo(ApiConstants.mainEndpoints.join(', ')),
                style: TextStyle(fontSize: 11, color: AppColors.muted),
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
    final tr = context.l10n;
    final a = activity;
    final (icon, color, background) = switch (a.type) {
      ActivityType.sale => (Icons.receipt_long_outlined, AppColors.green, AppColors.greenSoft),
      ActivityType.payroll => (Icons.payments_outlined, AppColors.orange, AppColors.orangeSoft),
      ActivityType.store => (Icons.storefront_outlined, AppColors.blue, AppColors.blueSoft),
      ActivityType.employee => (Icons.badge_outlined, AppColors.purple, AppColors.purpleSoft),
      ActivityType.profile => (Icons.person_outline, AppColors.muted, AppColors.surfaceSoft),
    };
    final amount = a.amount;
    final detail = [if (a.action != null) tr.activityAction(a.action!), if (a.detail.isNotEmpty) a.detail].join(' · ');
    final time = Text(formatTimeAgo(a.time), style: TextStyle(fontSize: 11, color: AppColors.muted));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBox(icon, color: color, background: background),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13, color: AppColors.ink, height: 1.35),
                    children: [
                      TextSpan(text: '${tr.activityType(a.type)}: '),
                      TextSpan(
                        text: a.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
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
                if (detail.isNotEmpty || compact) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (detail.isNotEmpty) Text(detail, style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                      if (compact) time,
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (!compact) ...[const SizedBox(width: 12), time],
        ],
      ),
    );
  }
}

/// Lead of the dashboard: today's sales as a big counting number over a real photo of a
/// cosmetics shop, tinted with the palette's dark surface; the two main actions live here.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.d, required this.change, required this.currency});

  final DashboardModel d;
  final double? change;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final tint = AppColors.navy;
    final up = (change ?? 0) >= 0;
    return Container(
      key: const Key('dashboard-hero'),
      constraints: const BoxConstraints(minHeight: 232),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: tint.withValues(alpha: 0.10), blurRadius: 18, offset: const Offset(0, 6))],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: PhotoSlideshow(images: ['assets/images/cosmetics_shop.jpg'], hold: Duration(seconds: 9)),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [tint.withValues(alpha: 0.96), tint.withValues(alpha: 0.82), tint.withValues(alpha: 0.30)],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tr.kpiTodaySales, style: const TextStyle(color: Color(0xFFD5DEE8), fontSize: 14)),
                const SizedBox(height: 6),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 10,
                  children: [
                    NumberTicker(
                      value: d.todaySales,
                      format: currency.amount,
                      style: const TextStyle(
                        fontFamily: AppTheme.display,
                        color: Colors.white,
                        fontSize: 52,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.6,
                        fontFeatures: AppTheme.numbers,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        currency.code,
                        style: const TextStyle(color: Color(0xFFD5DEE8), fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (change != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(up ? Icons.trending_up : Icons.trending_down, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              formatPercent(change!),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      tr.salesCount(d.todaySalesCount),
                      style: const TextStyle(color: Color(0xFFD5DEE8), fontSize: 12.5),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ShimmerSweep(
                      child: FilledButton.icon(
                        key: const Key('record-sale'),
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.navy),
                        onPressed: () => RecordSaleDialog.show(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(tr.recordSale),
                      ),
                    ),
                    OutlinedButton.icon(
                      key: const Key('hero-ask-ai'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      onPressed: () => context.read<HomeViewModel>().select(AppSection.assistant),
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: Text(tr.navAssistant),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Doorway to the assistant: the orb, one line, and two real questions that are sent on tap.
class _AiCard extends StatelessWidget {
  const _AiCard();

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    void ask(String q) {
      context.read<AssistantViewModel>().send(q, language: Localizations.localeOf(context).languageCode);
      context.read<HomeViewModel>().select(AppSection.assistant);
    }

    Widget chip(Key key, String q) => Pressable(
      lift: false,
      radius: 12,
      child: Material(
        color: AppColors.card.withValues(alpha: AppColors.isDark ? 0.6 : 0.85),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: key,
          borderRadius: BorderRadius.circular(12),
          onTap: () => ask(q),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    q,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: AppColors.ink),
                  ),
                ),
                Icon(Icons.north_east, size: 15, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );

    return Container(
      key: const Key('dashboard-ai'),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.goldSoft, AppColors.tealSoft],
        ),
        border: AppColors.isDark ? Border.all(color: AppColors.border) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const AiOrb(size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tr.askAssistant,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.display,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(tr.assistantLiveData, style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 14),
          chip(const Key('ai-card-sales'), tr.askSales),
          const SizedBox(height: 8),
          chip(const Key('ai-card-stores'), tr.askStores),
        ],
      ),
    );
  }
}
