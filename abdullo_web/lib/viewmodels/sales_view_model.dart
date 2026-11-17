import '../core/utils/format.dart';
import '../models/chart_point_model.dart';
import '../models/page_model.dart';
import '../models/sale_model.dart';
import '../models/sales_report_model.dart';
import '../services/sales_service.dart';
import 'base_view_model.dart';

enum SalesRange { today, week, month, custom }

/// Sales page. The list is paged on the server (`?page=&limit=`).
class SalesViewModel extends BaseViewModel {
  SalesViewModel(this._service);

  static const pageSize = 6;

  final SalesService _service;
  PageModel<SaleModel>? _page;
  double? _previousTotal;
  SalesReportModel? _today;
  SalesReportModel? _week;
  SalesReportModel? _month;
  bool _isSaving = false;
  SaleModel? _lastSaved;
  String? _storeId;
  SalesRange _range = SalesRange.today;
  DateTime? _customFrom;
  DateTime? _customTo;
  String _query = '';
  int _pageIndex = 0;
  DateTime _updatedAt = DateTime.now();

  bool get hasData => _page != null;
  bool get isSaving => _isSaving;
  SaleModel? get lastSaved => _lastSaved;
  String? get storeFilter => _storeId;
  SalesRange get range => _range;
  DateTime? get customFrom => _customFrom;
  DateTime? get customTo => _customTo;
  int get page => _pageIndex;
  DateTime get updatedAt => _updatedAt;

  double get todayTotal => _today?.totalAmount ?? 0;
  double get monthTotal => _month?.totalAmount ?? 0;

  /// Rows of the current page (page search + top-bar search applied on this page).
  List<SaleModel> filtered([String globalQuery = '']) => (_page?.items ?? const <SaleModel>[])
      .where((s) => _query.isEmpty || s.searchText.contains(_query))
      .where((s) => globalQuery.isEmpty || s.searchText.contains(globalQuery))
      .toList();

  /// Total of ALL entries in the filter (from the server).
  double get filteredTotal => _page?.totalAmount ?? 0;
  int get entryCount => _page?.total ?? 0;
  int get pageCount => (_page?.pages ?? 1) < 1 ? 1 : _page!.pages;

  double? changeVsPrevious() {
    final prev = _previousTotal;
    if (prev == null || prev == 0) return null;
    return percentChange(filteredTotal, prev);
  }

  /// Last 7 days (from /api/sales/weekly).
  List<ChartPointModel> get last7Days {
    final today = dateOnly(DateTime.now());
    final byDate = {for (final d in _week?.byDay ?? const <DaySalesModel>[]) dateOnly(d.date): d};
    return [
      for (var i = 6; i >= 0; i--)
        () {
          final day = today.subtract(Duration(days: i));
          return ChartPointModel(
            date: day,
            revenue: byDate[day]?.totalAmount ?? 0,
            count: byDate[day]?.salesCount ?? 0,
          );
        }(),
    ];
  }

  /// Stores that already have a sale today.
  int get storesReportedToday => _today?.stores.where((s) => s.salesCount > 0).length ?? 0;

  (DateTime, DateTime) _bounds() {
    final today = dateOnly(DateTime.now());
    return switch (_range) {
      SalesRange.today => (today, today),
      SalesRange.week => (today.subtract(const Duration(days: 6)), today),
      SalesRange.month => (DateTime(today.year, today.month), today),
      SalesRange.custom => (dateOnly(_customFrom ?? today), dateOnly(_customTo ?? today)),
    };
  }

  Future<void> load() => runTask(() async {
    final now = DateTime.now();
    final (today, week, month) = await (
      _service.daily(),
      _service.weekly(),
      _service.monthly(month: now.month, year: now.year),
    ).wait;
    _today = today;
    _week = week;
    _month = month;
    await _loadPage();
  });

  Future<void> _loadPage() async {
    final (from, to) = _bounds();
    final days = to.difference(from).inDays + 1;
    final (page, previous) = await (
      _service.list(storeId: _storeId, startDate: from, endDate: to, page: _pageIndex + 1, limit: pageSize),
      _service.list(
        storeId: _storeId,
        startDate: from.subtract(Duration(days: days)),
        endDate: from.subtract(const Duration(days: 1)),
        limit: 1,
      ),
    ).wait;
    _page = page;
    _previousTotal = previous.totalAmount;
    _updatedAt = DateTime.now();
  }

  Future<void> _reloadPage() => runTask(_loadPage);

  void setStoreFilter(String? storeId) {
    _storeId = storeId;
    _pageIndex = 0;
    _reloadPage();
  }

  void setRange(SalesRange range) {
    _range = range;
    _pageIndex = 0;
    _reloadPage();
  }

  void setCustomRange(DateTime from, DateTime to) {
    _customFrom = from;
    _customTo = to;
    _range = SalesRange.custom;
    _pageIndex = 0;
    _reloadPage();
  }

  void setQuery(String v) {
    _query = v.trim().toLowerCase();
    notifySafe();
  }

  void goToPage(int page) {
    _pageIndex = page;
    _reloadPage();
  }

  void dismissBanner() {
    _lastSaved = null;
    notifySafe();
  }

  /// POST /api/sales. Returns `null` or the error code.
  Future<String?> recordSale({
    required String storeId,
    required double amount,
    DateTime? date,
    String description = '',
  }) => _save(() async {
    _lastSaved = await _service.create(
      storeId: storeId,
      amount: amount,
      saleDate: date ?? DateTime.now(),
      description: description,
    );
  });

  /// PUT /api/sales/{id}.
  Future<String?> updateSale(
    SaleModel sale, {
    required String storeId,
    required double amount,
    required DateTime date,
    String description = '',
  }) => _save(() async {
    await _service.update(sale.id, storeId: storeId, amount: amount, saleDate: date, description: description);
  });

  /// DELETE /api/sales/{id}.
  Future<String?> deleteSale(SaleModel sale) => _save(() => _service.delete(sale.id));

  Future<String?> _save(Future<void> Function() action) async {
    if (_isSaving) return 'BUSY';
    _isSaving = true;
    notifySafe();
    final error = await runAction(() async {
      await action();
      _pageIndex = 0;
      final now = DateTime.now();
      final (today, week, month) = await (
        _service.daily(),
        _service.weekly(),
        _service.monthly(month: now.month, year: now.year),
      ).wait;
      _today = today;
      _week = week;
      _month = month;
      await _loadPage();
    });
    _isSaving = false;
    notifySafe();
    return error;
  }
}
