import '../models/sale_model.dart';
import '../services/sales_service.dart';
import 'base_view_model.dart';

class SalesViewModel extends BaseViewModel {
  SalesViewModel(this._service);

  final SalesService _service;
  List<SaleModel> _sales = const [];
  bool _isSaving = false;
  bool _loaded = false;

  List<SaleModel> get sales => _sales;
  bool get hasData => _loaded;
  bool get isSaving => _isSaving;
  double get total => _sales.fold(0, (sum, s) => sum + s.amount);
  double get averageTicket => _sales.isEmpty ? 0 : total / _sales.length;

  List<SaleModel> filtered(String query) => query.isEmpty
      ? _sales
      : _sales
            .where(
              (s) =>
                  '${s.receipt} ${s.storeName} ${s.method.label} ${s.register}'.toLowerCase().contains(query),
            )
            .toList();

  Future<void> load() => runTask(() async {
    _sales = await _service.fetchSales();
    _loaded = true;
  }, errorMessage: 'Could not load sales.');

  /// Returns `true` when the sale was saved.
  Future<bool> recordSale({
    required String storeId,
    required double amount,
    required PaymentMethod method,
  }) async {
    if (_isSaving || amount <= 0) return false;
    _isSaving = true;
    notifySafe();
    try {
      final sale = await _service.recordSale(storeId: storeId, amount: amount, method: method);
      _sales = [sale, ..._sales];
      return true;
    } catch (_) {
      return false;
    } finally {
      _isSaving = false;
      notifySafe();
    }
  }
}
