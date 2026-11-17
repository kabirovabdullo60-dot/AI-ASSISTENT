import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/utils/json.dart';
import '../models/page_model.dart';
import '../models/sale_model.dart';
import '../models/sales_report_model.dart';

class SalesService {
  SalesService(this._api);

  final ApiClient _api;

  /// GET /api/sales (or /api/sales/store/{id}) — newest first.
  Future<PageModel<SaleModel>> list({
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
    String sort = '-saleDate,-createdAt',
  }) async {
    final query = <String, Object?>{
      'startDate': startDate == null ? null : isoDay(startDate),
      'endDate': endDate == null ? null : isoDay(endDate),
      'page': page,
      'limit': limit,
      'sort': sort,
    };
    final json = storeId == null
        ? await _api.get(ApiConstants.sales, query: query)
        : await _api.get(ApiConstants.salesOfStore(storeId), query: query);
    return PageModel.fromJson(json, SaleModel.fromJson);
  }

  Future<SaleModel> create({
    required String storeId,
    required double amount,
    required DateTime saleDate,
    String? description,
  }) async => SaleModel.fromJson(
    asJsonMap(
      await _api.post(ApiConstants.sales, {
        'storeId': storeId,
        'amount': money(amount),
        'saleDate': isoDay(saleDate),
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      }),
    ),
  );

  Future<SaleModel> update(
    String id, {
    String? storeId,
    double? amount,
    DateTime? saleDate,
    String? description,
  }) async => SaleModel.fromJson(
    asJsonMap(
      await _api.put(ApiConstants.sale(id), {
        'storeId': ?storeId,
        if (amount != null) 'amount': money(amount),
        if (saleDate != null) 'saleDate': isoDay(saleDate),
        'description': description == null || description.trim().isEmpty ? null : description.trim(),
      }),
    ),
  );

  Future<void> delete(String id) => _api.delete(ApiConstants.sale(id));

  Future<SalesReportModel> daily([DateTime? date]) async => SalesReportModel.fromJson(
    asJsonMap(await _api.get(ApiConstants.salesDaily, query: {'date': date == null ? null : isoDay(date)})),
  );

  Future<SalesReportModel> weekly({DateTime? startDate, DateTime? endDate}) async => SalesReportModel.fromJson(
    asJsonMap(
      await _api.get(
        ApiConstants.salesWeekly,
        query: {
          'startDate': startDate == null ? null : isoDay(startDate),
          'endDate': endDate == null ? null : isoDay(endDate),
        },
      ),
    ),
  );

  Future<SalesReportModel> monthly({int? month, int? year}) async => SalesReportModel.fromJson(
    asJsonMap(await _api.get(ApiConstants.salesMonthly, query: {'month': month, 'year': year})),
  );
}
