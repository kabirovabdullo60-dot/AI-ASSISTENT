import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/sales_report_model.dart';
import '../models/notification_link.dart';
import '../models/target_period.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/notifications_view_model.dart';
import '../viewmodels/sales_period.dart';
import '../widgets/activity_tile.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_text_field.dart';
import '../widgets/async_state_view.dart';
import '../widgets/figure_card.dart';
import '../widgets/notification_bell.dart';
import '../widgets/period_chips.dart';
import '../widgets/section_header.dart';
import '../widgets/share_bar_row.dart';
import '../widgets/stat_tile.dart';
import '../widgets/summary_card.dart';
import '../widgets/target_progress_card.dart';
import 'activity_view.dart';
import 'notifications_view.dart';

/// Home (OFAR layout): month sales card, today, period figures with the
/// change, this month's profit and the sales targets, salaries of the
/// month, stores and employees, top stores.
class HomeView extends StatelessWidget {
  const HomeView({
    required this.onOpenSales,
    required this.onOpenLink,
    super.key,
  });

  final VoidCallback onOpenSales;

  /// A notification was tapped: open its screen.
  final ValueChanged<NotificationLink> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<DashboardViewModel>();
    final notifications = context.watch<NotificationsViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHome),
        actions: [
          NotificationBell(
            unread: notifications.unreadCount,
            tooltip: l10n.notificationsTooltip,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ChangeNotifierProvider.value(
                  value: notifications,
                  child: NotificationsView(onOpenLink: onOpenLink),
                ),
              ),
            ),
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
          builder: (context) => _Body(vm: vm, onOpenSales: onOpenSales),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.vm, required this.onOpenSales});

  final DashboardViewModel vm;
  final VoidCallback onOpenSales;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final d = vm.dashboard!;
    const gap = SizedBox(height: AppSpacing.md);
    final top = [...?vm.topStores?.stores]
      ..sort((a, b) => a.rank.compareTo(b.rank));
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.xxxl,
      ),
      children: [
        SummaryCard(
          title: l10n.homeMonthSales,
          value: context.money(d.monthSales),
          parts: [
            (l10n.homeToday, context.money(d.todaySales)),
            (l10n.homeWeek, context.money(d.weekSales)),
          ],
        ),
        gap,
        StatTile(
          icon: Icons.point_of_sale_rounded,
          label: l10n.homeRevenueToday,
          value: context.money(d.todaySales),
          caption: l10n.salesCount(d.todaySalesCount),
          onTap: onOpenSales,
        ),
        const SizedBox(height: AppSpacing.xl),
        PeriodChips<SalesPeriod>(
          values: SalesPeriod.values,
          selected: vm.period,
          onSelected: vm.selectPeriod,
          label: (period) => switch (period) {
            SalesPeriod.today => l10n.periodToday,
            SalesPeriod.week => l10n.periodWeek,
            SalesPeriod.month => l10n.periodMonth,
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (vm.periodReport case final report?)
          AnimatedOpacity(
            opacity: vm.isPeriodLoading ? 0.5 : 1,
            duration: const Duration(milliseconds: 150),
            child: _PeriodFigures(report: report, period: vm.period),
          ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: l10n.homeTargetsProfit),
        FigureCard(
          label: l10n.homeMonthProfit,
          value: context.money(d.monthProfit, signed: true),
          valueColor: d.monthProfit >= 0 ? p.success : p.error,
          caption: l10n.homeProfitCaption(
            context.money(d.monthExpenses),
            d.monthMarginPercent == null
                ? l10n.profitNoSales
                : l10n.profitMargin(context.percent(d.monthMarginPercent!)),
          ),
        ),
        gap,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Target(
                  vm: vm,
                  period: TargetPeriod.week,
                  sales: d.weekSales,
                  target: d.weekTarget,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _Target(
                  vm: vm,
                  period: TargetPeriod.month,
                  sales: d.monthSales,
                  target: d.monthTarget,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: l10n.homeSalaries),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FigureCard(
                label: l10n.payrollDue,
                value: context.money(d.salaryDueThisMonth),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FigureCard(
                label: l10n.payrollPaidAmount,
                value: context.money(d.paidSalaryThisMonth),
                valueColor: p.success,
              ),
            ),
          ],
        ),
        gap,
        FigureCard(
          label: l10n.payrollRemaining,
          value: context.money(d.remainingSalaryThisMonth),
          valueColor: d.remainingSalaryThisMonth > 0 ? p.error : null,
          caption: l10n.homeRemainingTotal(
            context.money(d.remainingSalaryTotal),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(title: l10n.homeBusiness),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FigureCard(
                label: l10n.navStores,
                value: '${d.activeStores}',
                caption: l10n.homeOfTotal(d.totalStores),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FigureCard(
                label: l10n.navEmployees,
                value: '${d.activeEmployees}',
                caption: l10n.homeOfTotal(d.totalEmployees),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: l10n.homeTopStores,
          actionLabel: l10n.homeShowAll,
          onAction: onOpenSales,
        ),
        if (top.isEmpty)
          AppCard(
            child: Text(
              l10n.homeNoSales,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          )
        else
          AppCard(
            child: Column(
              children: [
                for (final (i, s) in top.take(5).indexed) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  ShareBarRow(
                    icon: Icons.storefront_outlined,
                    label: s.storeName,
                    value: context.money(s.totalAmount),
                    share: s.sharePercent / 100,
                    shareText: context.percent(s.sharePercent),
                  ),
                ],
              ],
            ),
          ),
        if (vm.recentActivity case final recent? when recent.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: l10n.activityTitle,
            actionLabel: l10n.homeShowAll,
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ActivityView()),
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [for (final a in recent) ActivityTile(activity: a)],
            ),
          ),
        ],
      ],
    );
  }
}

/// Sales of the chosen period and the average sale, with the change
/// against the previous period of the same length.
class _PeriodFigures extends StatelessWidget {
  const _PeriodFigures({required this.report, required this.period});

  final SalesReportModel report;
  final SalesPeriod period;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final change = report.changePercent;
    final compare = switch (period) {
      SalesPeriod.today => l10n.compareToday,
      SalesPeriod.week => l10n.compareWeek,
      SalesPeriod.month => l10n.compareMonth,
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: FigureCard(
            label: l10n.homePeriodSales,
            value: context.money(report.totalAmount),
            valueColor: p.success,
            caption: change == null
                ? l10n.homeNoComparison
                : l10n.homeChange(
                    context.percent(change, signed: true),
                    compare,
                  ),
            captionColor: change == null || change == 0
                ? null
                : change > 0
                ? p.success
                : p.error,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FigureCard(
            label: l10n.homeAverageSale,
            value: context.money(report.averageSaleAmount),
            caption: l10n.salesCount(report.salesCount),
          ),
        ),
      ],
    );
  }
}

/// A business-wide sales target with its progress; tap to set or change it.
class _Target extends StatelessWidget {
  const _Target({
    required this.vm,
    required this.period,
    required this.sales,
    required this.target,
  });

  final DashboardViewModel vm;
  final TargetPeriod period;
  final double sales;
  final double? target;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final goal = target;
    return TargetProgressCard(
      label: period == TargetPeriod.week ? l10n.targetWeek : l10n.targetMonth,
      sales: sales,
      salesText: context.money(sales),
      target: goal,
      targetText: goal == null ? null : context.money(goal),
      percentText: goal == null || goal <= 0
          ? null
          : l10n.targetDone(context.percent(sales / goal * 100)),
      emptyText: l10n.targetNotSet,
      onTap: () => showAppBottomSheet<void>(
        context,
        title: period == TargetPeriod.week
            ? l10n.targetSheetTitleWeek
            : l10n.targetSheetTitleMonth,
        builder: (_) => _TargetSheet(vm: vm, period: period, current: goal),
      ),
    );
  }
}

/// Enter the target amount and save it (`PUT /api/targets`).
class _TargetSheet extends StatefulWidget {
  const _TargetSheet({required this.vm, required this.period, this.current});

  final DashboardViewModel vm;
  final TargetPeriod period;
  final double? current;

  @override
  State<_TargetSheet> createState() => _TargetSheetState();
}

class _TargetSheetState extends State<_TargetSheet> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
    text: widget.current?.toStringAsFixed(2) ?? '',
  );
  bool _saving = false;
  Object? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final saved = context.l10n.targetSaved;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.vm.setTarget(
      widget.period,
      Validators.parseAmount(_amount.text)!,
    );
    if (!mounted) return;
    if (error == null) {
      feedback.showSuccess(saved);
      navigator.pop();
    } else {
      setState(() {
        _saving = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _form,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.lg,
          AppSpacing.screen,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.targetSheetHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _amount,
              label: l10n.fieldAmount,
              hint: '0,00',
              suffix: const Text('TJS'),
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) => Validators.amount(v, l10n),
              onSubmitted: (_) => _save(),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppInlineMessage(
                type: InlineMessageType.error,
                message: errorText(l10n, _error!),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.commonSave,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
