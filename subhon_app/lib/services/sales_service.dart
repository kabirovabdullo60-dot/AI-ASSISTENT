import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/local_date.dart';
import '../models/page_model.dart';
import '../models/sale_create_model.dart';
import '../models/sale_model.dart';
import '../models/sale_update_model.dart';
import '../models/sales_report_model.dart';

/// `Sales` (API.md): records and the daily / weekly / monthly reports.
class SalesService {
  SalesService(this._api);

  final ApiClient _api;

  Future<PageModel<SaleModel>> list({
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = ApiConstants.pageSize,
    String sort = '-saleDate',
  }) async => PageModel.fromJson(
    await _api.get(
          storeId == null ? '/api/sales' : '/api/sales/store/$storeId',
          query: {
            'startDate': startDate == null ? null : formatLocalDate(startDate),
            'endDate': endDate == null ? null : formatLocalDate(endDate),
            'page': page,
            'limit': limit,
            'sort': sort,
          },
        )
        as Map<String, dynamic>,
    SaleModel.fromJson,
  );

  Future<SaleModel> create(SaleCreateModel sale) async => SaleModel.fromJson(
    await _api.post('/api/sales', body: sale.toJson()) as Map<String, dynamic>,
  );

  Future<SaleModel> update(
    String id,
    SaleUpdateModel update, {
    Set<String> clear = const {},
  }) async => SaleModel.fromJson(
    await _api.put('/api/sales/$id', body: update.toJson(clear: clear))
        as Map<String, dynamic>,
  );

  Future<void> delete(String id) => _api.delete('/api/sales/$id');

  /// Today when [date] is null.
  Future<SalesReportModel> daily({DateTime? date}) async => _report(
    '/api/sales/daily',
    {'date': date == null ? null : formatLocalDate(date)},
  );

  /// The current week when no dates are given.
  Future<SalesReportModel> weekly({DateTime? startDate, DateTime? endDate}) =>
      _report('/api/sales/weekly', {
        'startDate': startDate == null ? null : formatLocalDate(startDate),
        'endDate': endDate == null ? null : formatLocalDate(endDate),
      });

  Future<SalesReportModel> monthly({int? month, int? year}) =>
      _report('/api/sales/monthly', {'month': month, 'year': year});

  Future<SalesReportModel> _report(
    String path,
    Map<String, Object?> query,
  ) async => SalesReportModel.fromJson(
    await _api.get(path, query: query) as Map<String, dynamic>,
  );
}
