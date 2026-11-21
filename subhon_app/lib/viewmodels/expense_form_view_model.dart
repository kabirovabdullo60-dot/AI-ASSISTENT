import '../core/network/api_client.dart';
import '../models/expense_category.dart';
import '../models/expense_create_model.dart';
import '../models/expense_model.dart';
import '../models/expense_update_model.dart';
import '../models/store_model.dart';
import '../models/store_status.dart';
import '../services/expense_service.dart';
import '../services/store_service.dart';
import 'form_view_model.dart';

/// Records an expense, or edits [initial]. Loads the stores to choose from
/// (an expense may also belong to the whole business).
class ExpenseFormViewModel extends FormViewModel {
  ExpenseFormViewModel(this._expenses, this._storesService, {this.initial});

  final ExpenseService _expenses;
  final StoreService _storesService;
  final ExpenseModel? initial;

  List<StoreModel> _stores = const [];
  bool _storesLoading = false;
  Object? _storesError;

  /// Active stores (and the store of the edited expense).
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

  /// [storeId] `null`: the whole business.
  Future<bool> save({
    required String? storeId,
    required ExpenseCategory category,
    required double amount,
    required DateTime expenseDate,
    required String description,
  }) => submit(() async {
    final text = description.trim().isEmpty ? null : description.trim();
    final current = initial;
    if (current == null) {
      await _expenses.create(
        ExpenseCreateModel(
          storeId: storeId,
          category: category,
          amount: amount,
          expenseDate: expenseDate,
          description: text,
        ),
      );
    } else {
      await _expenses.update(
        current.id,
        ExpenseUpdateModel(
          storeId: storeId,
          category: category,
          amount: amount,
          expenseDate: expenseDate,
          description: text,
        ),
        clear: ExpenseUpdateModel.clearable,
      );
    }
  });

  /// Deletes the edited expense (soft delete).
  Future<bool> delete() => submit(() => _expenses.delete(initial!.id));
}
