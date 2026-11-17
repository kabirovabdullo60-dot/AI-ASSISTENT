import '../core/utils/format.dart';
import '../models/disbursement_model.dart';
import '../models/payroll_model.dart';
import '../services/payroll_service.dart';
import 'base_view_model.dart';

enum PayrollTab {
  all('All'),
  paid('Fully Paid'),
  partial('Partial'),
  unpaid('Unpaid');

  const PayrollTab(this.label);
  final String label;
}

/// One row of "Store Budget Allocation".
typedef StoreBudget = ({String store, int staff, double total});

class PayrollViewModel extends BaseViewModel {
  PayrollViewModel(this._service);

  static const pageSize = 6;

  final PayrollService _service;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  List<PayrollModel> _items = const [];
  List<DisbursementModel> _disbursements = const [];
  bool _loaded = false;
  String? _payingId;
  PayrollTab _tab = PayrollTab.all;
  String? _store;
  String _query = '';
  int _page = 0;

  DateTime get month => _month;
  bool get isCurrentMonth => periodKey(_month) == periodKey(DateTime.now());
  List<PayrollModel> get items => _items;
  List<DisbursementModel> get disbursements => _disbursements;
  bool get hasData => _loaded;
  String? get payingId => _payingId;
  PayrollTab get tab => _tab;
  String? get storeFilter => _store;
  int get page => _page;

  double get totalPayroll => _items.fold(0, (s, p) => s + p.salary);
  double get disbursedTotal => _items.fold(0, (s, p) => s + p.disbursed);
  double get pendingTotal => _items.fold(0, (s, p) => s + p.remaining);
  int get pendingCount => _items.where((p) => p.remaining > 0).length;
  double get paidTotal => disbursedTotal;
  double get disbursedRatio => totalPayroll == 0 ? 0 : disbursedTotal / totalPayroll;
  int get branchCount => _items.map((p) => p.storeName).toSet().length;
  List<String> get storeNames => (_items.map((p) => p.storeName).toSet().toList())..sort();

  int countFor(PayrollTab tab) => _items.where((p) => _matchesTab(p, tab)).length;

  bool _matchesTab(PayrollModel p, PayrollTab tab) => switch (tab) {
    PayrollTab.all => true,
    PayrollTab.paid => p.status == PayStatus.paid,
    PayrollTab.partial => p.status == PayStatus.partial,
    PayrollTab.unpaid => p.status == PayStatus.unpaid,
  };

  /// Rows after tab, store, page search and top-bar search. Unpaid/partial first.
  List<PayrollModel> filtered([String globalQuery = '']) {
    bool matches(PayrollModel p, String q) =>
        q.isEmpty || '${p.employeeName} ${p.role} ${p.storeName}'.toLowerCase().contains(q);
    final list = _items
        .where((p) => _matchesTab(p, _tab))
        .where((p) => _store == null || p.storeName == _store)
        .where((p) => matches(p, _query) && matches(p, globalQuery))
        .toList();
    list.sort((a, b) => a.status.index == b.status.index ? 0 : (a.status == PayStatus.paid ? 1 : -1));
    return list;
  }

  int pageCount(int itemCount) => itemCount == 0 ? 1 : (itemCount / pageSize).ceil();

  List<PayrollModel> pageItems(List<PayrollModel> all) {
    final start = (_page * pageSize).clamp(0, all.length);
    return all.sublist(start, (start + pageSize).clamp(0, all.length));
  }

  List<StoreBudget> get budgetByStore {
    final map = <String, List<PayrollModel>>{};
    for (final p in _items) {
      map.putIfAbsent(p.storeName, () => []).add(p);
    }
    final rows = [
      for (final e in map.entries)
        (store: e.key, staff: e.value.length, total: e.value.fold<double>(0, (s, p) => s + p.salary)),
    ];
    rows.sort((a, b) => b.total.compareTo(a.total));
    return rows;
  }

  List<DisbursementModel> historyFor(String payrollId) =>
      _disbursements.where((d) => d.payrollId == payrollId).toList();

  PayrollModel? byId(String id) {
    for (final p in _items) {
      if (p.id == id) return p;
    }
    return null;
  }

  void setTab(PayrollTab tab) {
    _tab = tab;
    _page = 0;
    notifySafe();
  }

  void setStoreFilter(String? store) {
    _store = store;
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

  Future<void> previousMonth() => _setMonth(DateTime(_month.year, _month.month - 1));

  Future<void> nextMonth() => _setMonth(DateTime(_month.year, _month.month + 1));

  Future<void> _setMonth(DateTime month) {
    _month = month;
    _page = 0;
    return load();
  }

  Future<void> load() => runTask(() async {
    final period = periodKey(_month);
    final (items, paid) = await (_service.fetchPayroll(period), _service.fetchDisbursements(period)).wait;
    _items = items;
    _disbursements = paid;
    _loaded = true;
  }, errorMessage: 'Could not load payroll.');

  /// Returns `true` when the payment was saved.
  Future<bool> recordPayment(String payrollId, double amount, {String method = 'Bank Transfer'}) async {
    if (_payingId != null || amount <= 0) return false;
    _payingId = payrollId;
    notifySafe();
    try {
      final d = await _service.recordPayment(payrollId: payrollId, amount: amount, method: method);
      _disbursements = [d, ..._disbursements];
      _items = [for (final p in _items) p.id == payrollId ? p.copyWith(disbursed: p.disbursed + d.amount) : p];
      return true;
    } catch (_) {
      return false;
    } finally {
      _payingId = null;
      notifySafe();
    }
  }

  /// Pays the whole remaining amount.
  Future<bool> markPaid(String payrollId) {
    final p = byId(payrollId);
    return p == null ? Future.value(false) : recordPayment(payrollId, p.remaining);
  }
}
