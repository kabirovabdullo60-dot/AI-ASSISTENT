import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/expense_model.dart';
import '../models/page_model.dart';

class ExpenseService {
  ExpenseService(this._api);

  final ApiClient _api;

  /// GET /api/expenses — newest first; `totalAmount` = sum of all matching rows.
  Future<PageModel<ExpenseModel>> list({
    String? storeId,
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 100,
  }) async => PageModel.fromJson(
    await _api.get(
      ApiConstants.expenses,
      query: {
        'storeId': storeId,
        'category': category?.api,
        'startDate': startDate == null ? null : isoDay(startDate),
        'endDate': endDate == null ? null : isoDay(endDate),
        'page': page,
        'limit': limit,
      },
    ),
    ExpenseModel.fromJson,
  );

  Future<ExpenseModel> create(ExpenseModel e) async =>
      ExpenseModel.fromJson(asJsonMap(await _api.post(ApiConstants.expenses, e.toJson())));

  Future<ExpenseModel> update(ExpenseModel e) async =>
      ExpenseModel.fromJson(asJsonMap(await _api.put(ApiConstants.expense(e.id), e.toJson())));

  Future<void> delete(String id) => _api.delete(ApiConstants.expense(id));
}
