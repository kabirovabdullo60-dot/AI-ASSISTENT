import '../models/expense_model.dart';
import '../models/profit_model.dart';
import '../services/expense_service.dart';
import '../services/reports_service.dart';
import 'base_view_model.dart';

/// Expenses page — /api/expenses (CRUD) + /api/reports/profit (this month).
class ExpensesViewModel extends BaseViewModel {
  ExpensesViewModel(this._service, this._reports);

  final ExpenseService _service;
  final ReportsService _reports;

  List<ExpenseModel> _expenses = const [];
  double _total = 0;
  ProfitModel? _profit;
  ExpenseCategory? _category;
  bool _loaded = false;
  bool _isSaving = false;

  List<ExpenseModel> get expenses => _expenses;

  /// Sum of all expenses matching the filter (server `totalAmount`).
  double get total => _total;
  ProfitModel? get profit => _profit;
  ExpenseCategory? get category => _category;
  bool get hasData => _loaded;
  bool get isSaving => _isSaving;

  List<ExpenseModel> filtered(String query) =>
      query.isEmpty ? _expenses : _expenses.where((e) => e.searchText.contains(query)).toList();

  Future<void> load() => runTask(_fetch);

  Future<void> _fetch() async {
    final (page, profit) = await (_service.list(category: _category), _reports.profit()).wait;
    _expenses = page.items;
    _total = page.totalAmount ?? page.items.fold(0, (s, e) => s + e.amount);
    _profit = profit;
    _loaded = true;
  }

  Future<void> setCategory(ExpenseCategory? c) async {
    if (c == _category) return;
    _category = c;
    await load();
  }

  Future<String?> save(ExpenseModel e, {required bool isNew}) async {
    _isSaving = true;
    notifySafe();
    final error = await runAction(() async {
      isNew ? await _service.create(e) : await _service.update(e);
      await _fetch();
    });
    _isSaving = false;
    notifySafe();
    return error;
  }

  Future<String?> delete(String id) => runAction(() async {
    await _service.delete(id);
    await _fetch();
  });
}
