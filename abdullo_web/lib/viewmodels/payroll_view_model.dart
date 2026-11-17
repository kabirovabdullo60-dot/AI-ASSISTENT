import '../models/payment_model.dart';
import '../models/payroll_model.dart';
import '../services/payroll_service.dart';
import 'base_view_model.dart';

enum PayrollTab { all, paid, partial, unpaid }

/// One row of "Store Budget Allocation".
typedef StoreBudget = ({String store, int staff, double total});

class PayrollViewModel extends BaseViewModel {
  PayrollViewModel(this._service);

  static const pageSize = 6;

  final PayrollService _service;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  MonthlyPayrollModel? _report;
  List<PaymentModel> _payments = const [];
  String? _payingId;
  PayrollTab _tab = PayrollTab.all;
  String? _storeId;
  String _query = '';
  int _page = 0;

  DateTime get month => _month;
  bool get isCurrentMonth => _month.year == DateTime.now().year && _month.month == DateTime.now().month;
  bool get isFutureMonth =>
      DateTime(_month.year, _month.month).isAfter(DateTime(DateTime.now().year, DateTime.now().month));
  List<PayrollModel> get items => _report?.items ?? const [];
  List<PaymentModel> get disbursements => _payments;
  bool get hasData => _report != null;
  String? get payingId => _payingId;
  PayrollTab get tab => _tab;
  String? get storeFilter => _storeId;
  int get page => _page;

  double get totalPayroll => _report?.totalDue ?? 0;
  double get disbursedTotal => _report?.totalPaid ?? 0;
  double get pendingTotal => _report?.totalRemaining ?? 0;
  int get pendingCount => items.where((p) => p.remaining > 0).length;
  double get disbursedRatio => totalPayroll == 0 ? 0 : disbursedTotal / totalPayroll;
  int get branchCount => items.map((p) => p.storeId).toSet().length;

  int countFor(PayrollTab tab) => items.where((p) => _matchesTab(p, tab)).length;

  bool _matchesTab(PayrollModel p, PayrollTab tab) => switch (tab) {
    PayrollTab.all => true,
    PayrollTab.paid => p.status == PayStatus.paid,
    PayrollTab.partial => p.status == PayStatus.partial,
    PayrollTab.unpaid => p.status == PayStatus.unpaid,
  };

  /// Unpaid / partial first.
  List<PayrollModel> filtered([String globalQuery = '']) {
    bool matches(PayrollModel p, String q) =>
        q.isEmpty || '${p.employeeName} ${p.role} ${p.storeName}'.toLowerCase().contains(q);
    final list = items
        .where((p) => _matchesTab(p, _tab))
        .where((p) => matches(p, _query) && matches(p, globalQuery))
        .toList();
    list.sort((a, b) => b.remaining.compareTo(a.remaining));
    return list;
  }

  int pageCount(int itemCount) => itemCount == 0 ? 1 : (itemCount / pageSize).ceil();

  List<PayrollModel> pageItems(List<PayrollModel> all) {
    final start = (_page * pageSize).clamp(0, all.length);
    return all.sublist(start, (start + pageSize).clamp(0, all.length));
  }

  List<StoreBudget> get budgetByStore {
    final map = <String, List<PayrollModel>>{};
    for (final p in items) {
      map.putIfAbsent(p.storeName, () => []).add(p);
    }
    return [
      for (final e in map.entries)
        (store: e.key, staff: e.value.length, total: e.value.fold<double>(0, (s, p) => s + p.salary)),
    ]..sort((a, b) => b.total.compareTo(a.total));
  }

  PayrollModel? byId(String employeeId) {
    for (final p in items) {
      if (p.employeeId == employeeId) return p;
    }
    return null;
  }

  void setTab(PayrollTab tab) {
    _tab = tab;
    _page = 0;
    notifySafe();
  }

  /// Filters on the server (`?storeId=`).
  void setStoreFilter(String? storeId) {
    _storeId = storeId;
    _page = 0;
    load();
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
    final (report, payments) = await (
      _service.monthly(month: _month.month, year: _month.year, storeId: _storeId),
      _service.payments(month: _month.month, year: _month.year, limit: 8),
    ).wait;
    _report = report;
    _payments = payments.items;
  });

  /// POST /api/payroll for the selected month. Returns `null` or the error code.
  Future<String?> recordPayment(String employeeId, double amount, {DateTime? paymentDate, String? note}) async {
    if (_payingId != null || amount <= 0) return 'BUSY';
    _payingId = employeeId;
    notifySafe();
    final error = await runAction(() async {
      await _service.pay(
        employeeId: employeeId,
        amount: amount,
        month: _month.month,
        year: _month.year,
        paymentDate: paymentDate,
        note: note,
      );
      await _reloadQuietly();
    });
    _payingId = null;
    notifySafe();
    return error;
  }

  /// Pays the whole remaining amount of this month.
  Future<String?> markPaid(String employeeId) {
    final p = byId(employeeId);
    return p == null ? Future.value('NOT_FOUND') : recordPayment(employeeId, p.remaining);
  }

  /// DELETE /api/payroll/{id}.
  Future<String?> cancelPayment(String paymentId) => runAction(() async {
    await _service.cancel(paymentId);
    await _reloadQuietly();
  });

  /// All months and payments of one employee (History dialog).
  Future<EmployeePayrollModel> history(String employeeId) => _service.ofEmployee(employeeId);

  Future<void> _reloadQuietly() async {
    final (report, payments) = await (
      _service.monthly(month: _month.month, year: _month.year, storeId: _storeId),
      _service.payments(month: _month.month, year: _month.year, limit: 8),
    ).wait;
    _report = report;
    _payments = payments.items;
  }
}
