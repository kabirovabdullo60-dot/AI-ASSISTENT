import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/local_date.dart';
import '../models/expense_category.dart';
import '../models/expense_create_model.dart';
import '../models/expense_model.dart';
import '../models/expense_update_model.dart';
import '../models/page_model.dart';

/// `Expenses` (API.md): business expenses of a store or the whole business.
class ExpenseService {
  ExpenseService(this._api);

  final ApiClient _api;

  /// Newest first; the page's `totalAmount` sums every matching expense.
  Future<PageModel<ExpenseModel>> list({
    String? storeId,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = ApiConstants.pageSize,
  }) async => PageModel.fromJson(
    await _api.get(
          '/api/expenses',
          query: {
            'storeId': storeId,
            'category': category?.json,
            'startDate': startDate == null ? null : formatLocalDate(startDate),
            'endDate': endDate == null ? null : formatLocalDate(endDate),
            'page': page,
            'limit': limit,
          },
        )
        as Map<String, dynamic>,
    ExpenseModel.fromJson,
  );

  Future<ExpenseModel> get(String id) async => ExpenseModel.fromJson(
    await _api.get('/api/expenses/$id') as Map<String, dynamic>,
  );

  Future<ExpenseModel> create(ExpenseCreateModel expense) async =>
      ExpenseModel.fromJson(
        await _api.post('/api/expenses', body: expense.toJson())
            as Map<String, dynamic>,
      );

  Future<ExpenseModel> update(
    String id,
    ExpenseUpdateModel update, {
    Set<String> clear = const {},
  }) async => ExpenseModel.fromJson(
    await _api.put('/api/expenses/$id', body: update.toJson(clear: clear))
        as Map<String, dynamic>,
  );

  Future<void> delete(String id) => _api.delete('/api/expenses/$id');
}
