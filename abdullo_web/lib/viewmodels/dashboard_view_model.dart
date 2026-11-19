import '../core/network/api_client.dart';
import '../core/utils/format.dart';
import '../models/activity_model.dart';
import '../models/chart_point_model.dart';
import '../models/dashboard_model.dart';
import '../models/sales_report_model.dart';
import '../services/activity_service.dart';
import '../services/payroll_service.dart';
import '../services/reports_service.dart';
import '../services/sales_service.dart';
import '../services/target_service.dart';
import 'base_view_model.dart';

enum ChartRange { weekly, monthly }

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel(this._reports, this._sales, this._payroll, this._activityLog, this._targets, {DateTime? since})
    : _since = since == null ? null : DateTime(since.year, since.month, since.day);

  /// Registration day of the account: a new business sees its chart start on that day,
  /// not 24 empty days earlier.
  final DateTime? _since;

  static const chartDays = 24;

  final ReportsService _reports;
  final SalesService _sales;
  final PayrollService _payroll;
  final ActivityService _activityLog;
  final TargetService _targets;

  DashboardModel? _dashboard;
  SalesReportModel? _today;
  SalesReportModel? _week;
  SalesReportModel? _month;
  SalesReportModel? _comparison;
  List<ChartPointModel> _daily = const [];
  List<ActivityModel> _activity = const [];
  ChartRange _range = ChartRange.monthly;
  ActivityType? _activityFilter;
  bool? _apiOnline;

  DashboardModel? get dashboard => _dashboard;

  /// GET /health/ready — `null` while unknown.
  bool? get apiOnline => _apiOnline;

  /// Today vs yesterday, this week vs last, this month vs last.
  double? get todayChange => _today?.changePercent;
  double? get weekChange => _week?.changePercent;
  double? get monthChange => _month?.changePercent;
  SalesReportModel? get monthReport => _month;

  /// Stores ranked by sales this month (/api/reports/store-comparison).
  List<StoreSalesModel> get topStores =>
      List.of(_comparison?.stores ?? const <StoreSalesModel>[])..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

  ChartRange get range => _range;
  ActivityType? get activityFilter => _activityFilter;

  List<ChartPointModel> get chartPoints =>
      _range == ChartRange.weekly && _daily.length > 7 ? _daily.sublist(_daily.length - 7) : _daily;

  int get peakIndex {
    final points = chartPoints;
    var best = -1;
    for (var i = 0; i < points.length; i++) {
      if (points[i].revenue > 0 && (best < 0 || points[i].revenue > points[best].revenue)) best = i;
    }
    return best;
  }

  /// Average per day over the chart period.
  double get averageDaily => _daily.isEmpty ? 0 : _daily.fold<double>(0, (s, p) => s + p.revenue) / _daily.length;

  List<ActivityModel> activity(String query) => _activity
      .where((a) => _activityFilter == null || a.type == _activityFilter)
      .where((a) => query.isEmpty || a.searchText.contains(query))
      .toList();

  Future<void> load() => runTask(() async {
    _reports.healthy().then((ok) {
      _apiOnline = ok;
      notifySafe();
    });
    final now = DateTime.now();
    final today = dateOnly(now);
    final (dashboard, daily, week, month, comparison, log) = await (
      _reports.dashboard(),
      _sales.daily(),
      _sales.weekly(),
      _reports.monthlySales(month: now.month, year: now.year),
      _reports.storeComparison(startDate: DateTime(now.year, now.month), endDate: today),
      _loadActivityLog(),
    ).wait;
    _dashboard = dashboard;
    _today = daily;
    _week = week;
    _month = month;
    _comparison = comparison;
    _daily = await _loadChart(today, month);
    _activity = log.isNotEmpty ? log : await _recentMoney();
  });

  /// GET /api/activity. Empty (or failing) → the feed is built from sales + payments instead.
  Future<List<ActivityModel>> _loadActivityLog() async {
    try {
      return (await _activityLog.list(limit: 20)).items;
    } on ApiException {
      return const [];
    }
  }

  /// Fallback feed: latest sales (+) and salary payments (-), newest first.
  Future<List<ActivityModel>> _recentMoney() async {
    final (recentSales, recentPayments) = await (
      _sales.list(limit: 6, sort: '-createdAt'),
      _payroll.payments(limit: 6),
    ).wait;
    return [
      for (final s in recentSales.items)
        ActivityModel(
          id: 's${s.id}',
          type: ActivityType.sale,
          title: s.storeName,
          amount: s.amount,
          time: s.createdAt ?? s.saleDate,
          detail: s.description ?? '',
        ),
      for (final p in recentPayments.items)
        ActivityModel(
          id: 'p${p.id}',
          type: ActivityType.payroll,
          title: p.employeeName,
          amount: -p.amount,
          time: p.createdAt ?? p.paymentDate,
          detail: p.note ?? '',
        ),
    ]..sort((a, b) => b.time.compareTo(a.time));
  }

  /// Last [chartDays] days — but never before the registration day; falls back to this
  /// month's report if the backend limits the range.
  Future<List<ChartPointModel>> _loadChart(DateTime today, SalesReportModel month) async {
    DateTime notBeforeSignUp(DateTime d) {
      final since = _since;
      return since != null && since.isAfter(d) && !since.isAfter(today) ? since : d;
    }

    final start = notBeforeSignUp(today.subtract(const Duration(days: chartDays - 1)));
    SalesReportModel report;
    try {
      report = await _reports.weeklySales(startDate: start, endDate: today);
    } on ApiException {
      report = month;
    }
    final byDate = {for (final d in report.byDay) dateOnly(d.date): d};
    final from = report == month ? notBeforeSignUp(DateTime(today.year, today.month)) : start;
    return [
      for (var d = from; !d.isAfter(today); d = DateTime(d.year, d.month, d.day + 1))
        ChartPointModel(date: d, revenue: byDate[d]?.totalAmount ?? 0, count: byDate[d]?.salesCount ?? 0),
    ];
  }

  /// Business-wide targets → PUT /api/targets (only the ones given), then reload.
  Future<String?> saveTargets({double? week, double? month}) => runAction(() async {
    await (
      week == null ? Future<void>.value() : _targets.put(TargetPeriod.week, week),
      month == null ? Future<void>.value() : _targets.put(TargetPeriod.month, month),
    ).wait;
    _dashboard = await _reports.dashboard();
  });

  void setRange(ChartRange range) {
    if (range == _range) return;
    _range = range;
    notifySafe();
  }

  void setActivityFilter(ActivityType? type) {
    _activityFilter = type;
    notifySafe();
  }
}
