import '../models/payroll_model.dart';
import '../services/payroll_service.dart';
import 'base_view_model.dart';

class PayrollViewModel extends BaseViewModel {
  PayrollViewModel(this._service);

  final PayrollService _service;
  List<PayrollModel> _items = const [];
  bool _loaded = false;
  String? _payingId;

  List<PayrollModel> get items => _items;
  bool get hasData => _loaded;
  String? get payingId => _payingId;

  Iterable<PayrollModel> get _pending => _items.where((p) => !p.isPaid);
  int get pendingCount => _pending.length;
  double get pendingTotal => _pending.fold(0, (sum, p) => sum + p.amount);
  double get paidTotal => _items.where((p) => p.isPaid).fold(0, (sum, p) => sum + p.amount);

  /// Unpaid first.
  List<PayrollModel> filtered(String query) {
    final list = query.isEmpty
        ? List.of(_items)
        : _items
              .where((p) => '${p.employeeName} ${p.role} ${p.storeName}'.toLowerCase().contains(query))
              .toList();
    list.sort((a, b) => (a.isPaid ? 1 : 0).compareTo(b.isPaid ? 1 : 0));
    return list;
  }

  Future<void> load() => runTask(() async {
    _items = await _service.fetchPayroll();
    _loaded = true;
  }, errorMessage: 'Could not load salaries.');

  /// Returns `true` when the salary was marked paid.
  Future<bool> markPaid(String id) async {
    if (_payingId != null) return false;
    _payingId = id;
    notifySafe();
    try {
      final paid = await _service.markPaid(id);
      _items = [for (final p in _items) p.id == id ? paid : p];
      return true;
    } catch (_) {
      return false;
    } finally {
      _payingId = null;
      notifySafe();
    }
  }
}
