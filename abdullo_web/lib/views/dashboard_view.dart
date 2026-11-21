import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../widgets/icon_box.dart';
import '../widgets/kpi_card.dart';
import '../widgets/page_body.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';
import '../widgets/motion/number_ticker.dart';
import '../viewmodels/assistant_view_model.dart';
import '../core/theme/app_theme.dart';
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
  const _DashboardContent({required this.vm, required this.d});

  final DashboardViewModel vm;
  final DashboardModel d;

  /// A money figure with its change in words against its window ("+51.8% vs last month").
  KpiCard _money(String title, double tjs, double? change, String window, String caption, Currency cur) => KpiCard(
    title: title,
    value: cur.amount(tjs),
    number: tjs,
    format: cur.amount,
    unit: cur.code,
    badge: change == null ? null : '${formatPercent(change)} $window',
    badgeTone: change == null || change == 0
        ? BadgeTone.neutral
        : (change > 0 ? BadgeTone.positive : BadgeTone.negative),
    caption: change == null ? caption : null,
  );

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final cur = context.select<SettingsViewModel, Currency>((s) => s.currency);

    // Balances that the day does not move much, in one divided strip.
    final strip = KpiStrip(
      key: const Key('dashboard-balances'),
      children: [
        _money(tr.kpiWeeklySales, d.weekSales, vm.weekChange, tr.vsLastWeek, tr.salesCount(d.weekSalesCount), cur),
        _money(tr.kpiMonthlySales, d.monthSales, vm.monthChange, tr.vsLastMonth, tr.salesCount(d.monthSalesCount), cur),
        KpiCard(
          key: const Key('month-profit-kpi'),
          title: tr.profitThisMonth,
          value: cur.amount(d.monthProfit),
          number: d.monthProfit,
          format: cur.amount,
          unit: cur.code,
          caption: '${tr.navExpenses}: ${cur.format(d.monthExpenses)}',
        ),
        KpiCard(
          title: tr.kpiUnpaidSalaries,
          value: cur.amount(d.remainingSalaryThisMonth),
          number: d.remainingSalaryThisMonth,
          format: cur.amount,
          unit: cur.code,
          caption: tr.ofDue(cur.format(d.salaryDueThisMonth)),
          highlight: d.remainingSalaryThisMonth > 0,
        ),
        KpiCard(title: tr.storesActiveShort, value: '${d.activeStores}', caption: tr.ofRegistered(d.totalStores)),
        KpiCard(title: tr.staffActiveShort, value: '${d.activeEmployees}', caption: tr.ofTotal(d.totalEmployees)),
      ],
    );

    return PageBody(
      title: tr.overviewTitle,
      // The finding: today's takings and what is still owed, read before anything else.
      subtitle: tr.overviewFinding(cur.format(d.todaySales), d.todaySalesCount, cur.format(d.remainingSalaryThisMonth)),
      actions: [
        const _DateChip(),
        _CurrencyToggle(selected: cur),
        // The most frequent job, one click from the first screen.
        FilledButton.icon(
          key: const Key('record-sale'),
          onPressed: () => RecordSaleDialog.show(context),
          icon: const Icon(Icons.add, size: 18),
          label: Text(tr.recordSale),
        ),
      ],
      children: [
        _TakingsCard(vm: vm, d: d, currency: cur),
        const SizedBox(height: AppTheme.gap),
        strip,
        const SizedBox(height: AppTheme.gap),
        LayoutBuilder(
          builder: (context, c) {
            final stores = _TopStoresCard(stores: vm.topStores, currency: cur);
            const ai = _AiCard();
            if (c.maxWidth < 1000) {
              return Column(
                children: [
                  stores,
                  const SizedBox(height: AppTheme.gap),
                  ai,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: stores),
                const SizedBox(width: AppTheme.gap),
                const Expanded(flex: 2, child: ai),
              ],
            );
          },
        ),
        const SizedBox(height: AppTheme.gap),
        _GoalsCard(d: d, currency: cur),
        const SizedBox(height: AppTheme.gap),
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontFeatures: AppTheme.numbers),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            // The fill is the true ratio; reached targets turn green.
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1).toDouble(),
              minHeight: 6,
              backgroundColor: AppColors.surfaceSoft,
              color: ratio >= 1 ? AppColors.green : AppColors.ink,
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
            fontWeight: FontWeight.w600,
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
    // On a phone the date is not worth a row above the data.
    if (MediaQuery.sizeOf(context).width < 600) return const SizedBox.shrink();
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
          Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.muted),
          const SizedBox(width: 6),
          Text(
            context.l10n.todayDate(formatDate(DateTime.now())),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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

/// The screen's answer: today's takings (the one data hue, the largest figure), its change
/// against yesterday, and the days behind it as one bar per day with today in the same hue.
class _TakingsCard extends StatelessWidget {
  const _TakingsCard({required this.vm, required this.d, required this.currency});

  final DashboardViewModel vm;
  final DashboardModel d;
  final Currency currency;

  List<String> _labels(bool narrow, AppLocalizations tr) {
    final points = vm.chartPoints;
    final n = points.length;
    if (vm.range == ChartRange.weekly) {
      return [for (var i = 0; i < n; i++) i == n - 1 ? tr.today : formatWeekday(points[i].date)];
    }
    // One step all the way (every 5th day from the end), today last.
    final step = narrow ? 10 : 5;
    return [
      for (var i = 0; i < n; i++)
        if (i == n - 1)
          tr.today
        else if ((n - 1 - i) % step == 0 && n - 1 - i >= step)
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
    final change = vm.todayChange;
    final month = vm.monthReport;
    final changeColor = change == null || change == 0
        ? AppColors.muted
        : (change > 0 ? AppColors.green : AppColors.red);

    Widget figure(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.muted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFeatures: AppTheme.numbers),
        ),
      ],
    );

    return Card(
      key: const Key('dashboard-hero'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 560;
            final range = SegmentedButton<ChartRange>(
              key: const Key('chart-range'),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontFamily: 'Onest', fontSize: 13, fontWeight: FontWeight.w500),
              ),
              segments: [
                ButtonSegment(value: ChartRange.weekly, label: Text(tr.weekly)),
                ButtonSegment(value: ChartRange.monthly, label: Text(tr.monthly)),
              ],
              selected: {vm.range},
              onSelectionChanged: (s) => vm.setRange(s.first),
            );
            final answer = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr.kpiTodaySales, style: TextStyle(fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    NumberTicker(
                      value: d.todaySales,
                      format: currency.amount,
                      style: TextStyle(
                        fontFamily: AppTheme.display,
                        color: AppColors.data,
                        fontSize: 36,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                        fontFeatures: AppTheme.figure,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      currency.code,
                      style: TextStyle(color: AppColors.muted, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13, color: AppColors.muted, fontFeatures: AppTheme.numbers),
                    children: [
                      if (change != null) ...[
                        TextSpan(
                          text: formatPercent(change),
                          style: TextStyle(color: changeColor, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(text: ' ${tr.vsYesterday} · '),
                      ],
                      TextSpan(text: tr.salesCount(d.todaySalesCount)),
                    ],
                  ),
                ),
              ],
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (narrow) ...[
                  answer,
                  const SizedBox(height: 12),
                  range,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: answer),
                      range,
                    ],
                  ),
                const SizedBox(height: 16),
                RevenueChart(
                  points: points,
                  peakIndex: peak,
                  xLabels: _labels(narrow, tr),
                  peakLabel: peak >= 0 ? currency.amount(points[peak].revenue) : '',
                  tooltipLines: (i) => [
                    '${formatWeekday(points[i].date)}, ${formatDay(points[i].date)}',
                    tr.chartRevenue(currency.format(points[i].revenue)),
                    tr.chartSales(points[i].count),
                  ],
                  height: narrow ? 180 : 220,
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 40,
                  runSpacing: 12,
                  children: [
                    figure(
                      tr.averageDaily.trim().replaceAll(RegExp(r'[:：]\s*$'), ''),
                      currency.format(vm.averageDaily),
                    ),
                    figure(tr.averageSale, currency.format(month?.averageSaleAmount ?? 0)),
                    figure(tr.salesThisMonth, tr.salesCount(d.monthSalesCount)),
                    figure(tr.unpaidAllMonths, currency.format(d.remainingSalaryTotal)),
                  ],
                ),
              ],
            );
          },
        ),
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
      subtitle: tr.rankedSubtitle,
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
                backgroundColor: AppColors.surfaceSoft,
                child: Text(
                  '$rank',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tr.salesCount(store.salesCount)}${change == null ? '' : ' · ${formatPercent(change)}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
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
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFeatures: AppTheme.numbers),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tr.shareValue(store.sharePercent.toStringAsFixed(0)),
                    style: TextStyle(fontSize: 12, color: AppColors.muted, fontFeatures: AppTheme.numbers),
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
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: first ? AppColors.ink : AppColors.barGray,
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

/// Doorway to the assistant: one line and two real questions that are sent on tap.
class _AiCard extends StatelessWidget {
  const _AiCard();

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    void ask(String q) {
      context.read<AssistantViewModel>().send(q, language: Localizations.localeOf(context).languageCode);
      context.read<HomeViewModel>().select(AppSection.assistant);
    }

    Widget question(Key key, String q) => InkWell(
      key: key,
      borderRadius: BorderRadius.circular(AppTheme.radiusControl),
      onTap: () => ask(q),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Text(q, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
            ),
            Icon(Icons.arrow_forward, size: 16, color: AppColors.muted),
          ],
        ),
      ),
    );

    return SectionCard(
      key: const Key('dashboard-ai'),
      title: tr.askAssistant,
      subtitle: tr.assistantLiveData,
      child: Column(
        children: [
          question(const Key('ai-card-sales'), tr.askSales),
          Divider(height: 1, color: AppColors.border),
          question(const Key('ai-card-stores'), tr.askStores),
          Divider(height: 1, color: AppColors.border),
          question(const Key('ai-card-salaries'), tr.askSalaries),
        ],
      ),
    );
  }
}
