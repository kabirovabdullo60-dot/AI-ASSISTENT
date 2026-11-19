import 'package:abdullo_web/core/network/api_client.dart';
import 'package:abdullo_web/core/network/token_storage.dart';
import 'package:abdullo_web/models/payroll_model.dart';
import 'package:abdullo_web/models/sales_report_model.dart';
import 'package:abdullo_web/services/payroll_service.dart';
import 'package:abdullo_web/services/sales_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late FakeBackend backend;
  late ApiClient api;

  setUp(() async {
    backend = setUpBackend();
    final tokens = TokenStorage();
    await tokens.load();
    api = ApiClient(client: backend.client, tokens: tokens);
  });

  test('money strings are parsed and sent as "1250.50"', () async {
    final sales = SalesService(api);
    final sale = await sales.create(storeId: 's1', amount: 1250.5, saleDate: backend.today);
    expect(sale.amount, 1250.5);
    expect(backend.sales.last['amount'], '1250.50');
  });

  test('backend errors become ApiException with the code', () async {
    final payroll = PayrollService(api);
    expect(
      () => payroll.pay(employeeId: 'e2', amount: 99999, month: backend.today.month, year: backend.today.year),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'PAYROLL_AMOUNT_EXCEEDS_REMAINING')),
    );
  });

  test('reports parse nullable changePercent and byDay', () async {
    final r = SalesReportModel.fromJson({
      'period': {'startDate': '2026-11-01', 'endDate': '2026-11-07'},
      'totalAmount': '10.00',
      'salesCount': 1,
      'changePercent': null,
      'byDay': [
        {'saleDate': '2026-11-02', 'totalAmount': '10.00', 'salesCount': 1},
      ],
    });
    expect(r.changePercent, isNull);
    expect(r.byDay.single.date, DateTime(2026, 11, 2));
  });

  test('monthly payroll status', () async {
    final m = await PayrollService(api).monthly(month: backend.today.month, year: backend.today.year);
    expect(m.totalRemaining, 4200);
    expect(m.items.firstWhere((p) => p.employeeId == 'e3').status, PayStatus.partial);
  });

  test('network failure → NETWORK_ERROR', () async {
    final broken = ApiClient(client: _Broken(), tokens: TokenStorage());
    expect(
      () => broken.get('/health/ready', auth: false),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'NETWORK_ERROR')),
    );
  });
}

class _Broken extends FakeBackendClientThatThrows {}
