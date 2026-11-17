import '../core/constants/api_constants.dart';
import '../core/utils/json.dart';
import '../models/disbursement_model.dart';
import '../models/payroll_model.dart';
import 'base_service.dart';

class PayrollService extends BaseService {
  PayrollService({super.client, super.useMock});

  /// [period] like "2026-11".
  Future<List<PayrollModel>> fetchPayroll(String period) => mockOr(
    mock: (db) => db.payrollFor(period),
    api: () async => asJsonList(
      await client.get(ApiConstants.payroll, query: {'period': period}),
    ).map(PayrollModel.fromJson).toList(),
  );

  Future<List<DisbursementModel>> fetchDisbursements(String period) => mockOr(
    mock: (db) => db.disbursementsFor(period),
    api: () async => asJsonList(
      await client.get(ApiConstants.disbursements, query: {'period': period}),
    ).map(DisbursementModel.fromJson).toList(),
  );

  Future<DisbursementModel> recordPayment({
    required String payrollId,
    required double amount,
    required String method,
  }) => mockOr(
    mock: (db) => db.recordPayment(payrollId: payrollId, amount: amount, method: method),
    api: () async => DisbursementModel.fromJson(
      asJsonMap(await client.post(ApiConstants.payrollPayments(payrollId), {'amount': amount, 'method': method})),
    ),
  );
}
