import '../models/expense_category.dart';
import '../models/expense_model.dart';
import '../models/page_model.dart';
import '../models/store_model.dart';
import '../services/expense_service.dart';
import '../services/store_service.dart';
import 'paged_list_view_model.dart';

/// Expenses page by page (newest first), filtered by store, category and
/// dates, with the total of the filtered expenses.
class ExpensesViewModel extends PagedListViewModel<ExpenseModel> {
  ExpensesViewModel(this._expenses, this._storesService);

  final ExpenseService _expenses;
  final StoreService _storesService;

  String? _storeId;
  ExpenseCategory? _category;
  DateTime? _startDate;
  DateTime? _endDate;
  List<StoreModel> _stores = const [];

  String? get storeId => _storeId;
  ExpenseCategory? get category => _category;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  /// Stores for the filter (loaded with the first page).
  List<StoreModel> get stores => _stores;

  bool get isFiltered =>
      _storeId != null ||
      _category != null ||
      _startDate != null ||
      _endDate != null;

  Future<void> setFilter({
    String? storeId,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _storeId = storeId;
    _category = category;
    _startDate = startDate;
    _endDate = endDate;
    return load();
  }

  Future<void> clearFilter() => setFilter();

  @override
  Future<PageModel<ExpenseModel>> fetch(int page) async {
    if (page == 1 && _stores.isEmpty) {
      _stores = (await _storesService.list(limit: 100)).items;
    }
    return _expenses.list(
      storeId: _storeId,
      category: _category,
      startDate: _startDate,
      endDate: _endDate,
      page: page,
    );
  }
}
