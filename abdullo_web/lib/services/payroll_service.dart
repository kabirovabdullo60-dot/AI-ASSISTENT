import '../core/constants/api_constants.dart';
import '../core/utils/json.dart';
import '../models/payroll_model.dart';
import 'base_service.dart';

class PayrollService extends BaseService {
  PayrollService({super.client, super.useMock});

  Future<List<PayrollModel>> fetchPayroll() => mockOr(
    mock: (db) => List.of(db.payroll),
    api: () async => asJsonList(await client.get(ApiConstants.payroll)).map(PayrollModel.fromJson).toList(),
  );

  Future<PayrollModel> markPaid(String id) => mockOr(
    mock: (db) => db.markPaid(id),
    api: () async => PayrollModel.fromJson(asJsonMap(await client.post(ApiConstants.payrollPay(id)))),
  );
}
