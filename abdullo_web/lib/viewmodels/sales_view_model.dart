import '../core/utils/format.dart';
import '../models/sale_model.dart';
import '../services/sales_service.dart';
import 'base_view_model.dart';

enum SalesRange {
  today('Today'),
  week('This Week'),
  month('This Month'),
  custom('Custom Range');

  const SalesRange(this.label);
  final String label;
}

class SalesViewModel extends BaseViewModel {
  SalesViewModel(this._service);

  static const pageSize = 6;

  final SalesService _service;
  List<SaleModel> _sales = const [];
  bool _loaded = false;
  bool _isSaving = false;
  SaleModel? _lastSaved;
  String? _storeId;
  SalesRange _range = SalesRange.today;
  DateTime? _customFrom;
  DateTime? _customTo;
  String _query = '';
  int _page = 0;
  DateTime _updatedAt = DateTime.now();

  List<SaleModel> get sales => _sales;
  bool get hasData => _loaded;
  bool get isSaving => _isSaving;

  /// The entry shown in the green "Success" banner.
  SaleModel? get lastSaved => _lastSaved;
  String? get storeFilter => _storeId;
  SalesRange get range => _range;
  DateTime? get customFrom => _customFrom;
  DateTime? get customTo => _customTo;
  int get page => _page;
  DateTime get updatedAt => _updatedAt;

  double get total => _sales.fold(0, (sum, s) => sum + s.amount);
  double get averageTicket => _sales.isEmpty ? 0 : total / _sales.length;

  double get todayTotal => _sum(_sales.where((s) => isSameDay(s.date, DateTime.now())));

  double get monthTotal {
    final now = DateTime.now();
    return _sum(_sales.where((s) => s.date.year == now.year && s.date.month == now.month));
  }

  /// [from, to) of the selected range.
  (DateTime, DateTime) _bounds(SalesRange range) {
    final today = dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    return switch (range) {
      SalesRange.today => (today, tomorrow),
      SalesRange.week => (today.subtract(const Duration(days: 6)), tomorrow),
      SalesRange.month => (DateTime(today.year, today.month), tomorrow),
      SalesRange.custom => (dateOnly(_customFrom ?? today), dateOnly(_customTo ?? today).add(const Duration(days: 1))),
    };
  }

  Iterable<SaleModel> _inRange(DateTime from, DateTime to) =>
      _sales.where((s) => !s.date.isBefore(from) && s.date.isBefore(to) && (_storeId == null || s.storeId == _storeId));

  /// Entries after store, date range, page search and top-bar search.
  List<SaleModel> filtered([String globalQuery = '']) {
    final (from, to) = _bounds(_range);
    return _inRange(from, to)
        .where((s) => (_query.isEmpty || s.searchText.contains(_query)))
        .where((s) => globalQuery.isEmpty || s.searchText.contains(globalQuery))
        .toList();
  }

  double filteredTotal([String globalQuery = '']) => _sum(filtered(globalQuery));

  /// Change vs the same-length period right before; `null` if there is nothing to compare.
  double? changeVsPrevious() {
    final (from, to) = _bounds(_range);
    final length = to.difference(from);
    final prev = _sum(_inRange(from.subtract(length), from));
    if (prev == 0) return null;
    return percentChange(_sum(_inRange(from, to)), prev);
  }

  int pageCount(int itemCount) => itemCount == 0 ? 1 : (itemCount / pageSize).ceil();

  List<SaleModel> pageItems(List<SaleModel> all) {
    final start = (_page * pageSize).clamp(0, all.length);
    return all.sublist(start, (start + pageSize).clamp(0, all.length));
  }

  /// Today's sales per hour from 08:00 to 22:00 (15 values).
  List<double> get hourlyToday {
    final now = DateTime.now();
    final hours = List<double>.filled(15, 0);
    for (final s in _sales.where((s) => isSameDay(s.date, now))) {
      final h = s.date.hour - 8;
      if (h >= 0 && h < hours.length) hours[h] += s.amount;
    }
    return hours;
  }

  /// Stores that already sent today's entry.
  int get storesSyncedToday =>
      _sales.where((s) => isSameDay(s.date, DateTime.now())).map((s) => s.storeId).toSet().length;

  void setStoreFilter(String? storeId) {
    _storeId = storeId;
    _page = 0;
    notifySafe();
  }

  void setRange(SalesRange range) {
    _range = range;
    _page = 0;
    notifySafe();
  }

  void setCustomRange(DateTime from, DateTime to) {
    _customFrom = from;
    _customTo = to;
    _range = SalesRange.custom;
    _page = 0;
    notifySafe();
  }

  void setQuery(String v) {
    _query = v.trim().toLowerCase();
    _page = 0;
    notifySafe();
  }

  void goToPage(int page) {
    _page = page;
    notifySafe();
  }

  void dismissBanner() {
    _lastSaved = null;
    notifySafe();
  }

  Future<void> load() => runTask(() async {
    _sales = await _service.fetchSales();
    _loaded = true;
    _updatedAt = DateTime.now();
  }, errorMessage: 'Could not load sales.');

  /// Returns `true` when the entry was saved.
  Future<bool> recordSale({
    required String storeId,
    required double amount,
    DateTime? date,
    BalanceSplit split = BalanceSplit.balanced,
    String notes = '',
  }) async {
    if (_isSaving || amount <= 0) return false;
    _isSaving = true;
    notifySafe();
    try {
      final sale = await _service.recordSale(
        storeId: storeId,
        amount: amount,
        date: date ?? DateTime.now(),
        split: split,
        notes: notes.trim(),
      );
      _sales = [sale, ..._sales]..sort((a, b) => b.date.compareTo(a.date));
      _lastSaved = sale;
      _page = 0;
      _updatedAt = DateTime.now();
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSaving = false;
      notifySafe();
    }
  }

  static double _sum(Iterable<SaleModel> list) => list.fold(0, (sum, s) => sum + s.amount);
}
