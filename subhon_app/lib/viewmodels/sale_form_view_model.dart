import '../core/network/api_client.dart';
import '../models/sale_create_model.dart';
import '../models/sale_model.dart';
import '../models/sale_update_model.dart';
import '../models/store_model.dart';
import '../models/store_status.dart';
import '../services/sales_service.dart';
import '../services/store_service.dart';
import 'form_view_model.dart';

/// Records a sale, or edits [initial]. Loads the stores to choose from.
class SaleFormViewModel extends FormViewModel {
  SaleFormViewModel(this._sales, this._storesService, {this.initial});

  final SalesService _sales;
  final StoreService _storesService;
  final SaleModel? initial;

  List<StoreModel> _stores = const [];
  bool _storesLoading = false;
  Object? _storesError;

  /// Active stores (and the store of the edited sale).
  List<StoreModel> get stores => _stores;
  bool get storesLoading => _storesLoading;
  Object? get storesError => _storesError;
  bool get isEdit => initial != null;

  Future<void> loadStores() async {
    _storesLoading = true;
    _storesError = null;
    notifyListeners();
    try {
      final all = (await _storesService.list(limit: 100)).items;
      _stores = [
        for (final s in all)
          if (s.status == StoreStatus.active || s.id == initial?.storeId) s,
      ];
    } on ApiException catch (e) {
      _storesError = e;
    } finally {
      _storesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save({
    required String storeId,
    required double amount,
    required DateTime saleDate,
    required String description,
  }) => submit(() async {
    final text = description.trim().isEmpty ? null : description.trim();
    final current = initial;
    if (current == null) {
      await _sales.create(
        SaleCreateModel(
          storeId: storeId,
          amount: amount,
          saleDate: saleDate,
          description: text,
        ),
      );
    } else {
      await _sales.update(
        current.id,
        SaleUpdateModel(
          storeId: storeId,
          amount: amount,
          saleDate: saleDate,
          description: text,
        ),
        clear: SaleUpdateModel.clearable,
      );
    }
  });

  /// Deletes the edited sale (soft delete).
  Future<bool> delete() => submit(() => _sales.delete(initial!.id));
}
