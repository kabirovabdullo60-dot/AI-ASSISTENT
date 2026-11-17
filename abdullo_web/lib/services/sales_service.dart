import '../core/constants/api_constants.dart';
import '../core/utils/json.dart';
import '../models/sale_model.dart';
import 'base_service.dart';

class SalesService extends BaseService {
  SalesService({super.client, super.useMock});

  Future<List<SaleModel>> fetchSales() => mockOr(
    mock: (db) => List.of(db.sales),
    api: () async => asJsonList(await client.get(ApiConstants.sales)).map(SaleModel.fromJson).toList(),
  );

  Future<SaleModel> recordSale({
    required String storeId,
    required double amount,
    required PaymentMethod method,
  }) => mockOr(
    mock: (db) => db.recordSale(storeId: storeId, amount: amount, method: method),
    api: () async => SaleModel.fromJson(
      asJsonMap(
        await client.post(ApiConstants.sales, {'storeId': storeId, 'amount': amount, 'method': method.name}),
      ),
    ),
  );
}
