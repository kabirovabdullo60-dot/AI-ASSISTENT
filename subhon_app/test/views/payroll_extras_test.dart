import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/network/api_client.dart';
import 'package:subhon_app/models/salary_payment_method.dart';
import 'package:subhon_app/services/employee_service.dart';
import 'package:subhon_app/services/payroll_service.dart';
import 'package:subhon_app/services/sales_service.dart';
import 'package:subhon_app/widgets/app_button.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

Map<String, Object?> _summary() => {
  'currency': 'TJS',
  'asOf': '2026-11-18',
  'employeesCount': 6,
  'totalDue': '54000.00',
  'totalPaid': '42000.00',
  'totalRemaining': '12000.00',
  'currentMonth': {
    'year': 2026,
    'month': 11,
    'dueAmount': '18000.00',
    'paidAmount': '9000.00',
    'remainingAmount': '9000.00',
  },
  'items': <Object>[],
};

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('the payroll tab shows the unpaid total of all months; a '
      'payment is sent with its method', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json('GET', '/api/payroll/summary', _summary());
    stubHome(backend);
    backend.json('POST', '/api/payroll', ApiJson.payment(), status: 201);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Зарплаты');
    expect(find.text('Невыплачено за все месяцы'), findsOneWidget);
    expect(find.textContaining('12 000'), findsOneWidget);

    await tapText(tester, 'Шерзод Рахимов');
    await tapText(tester, 'Не указан');
    await tapText(tester, 'Банковский перевод');
    await tester.tap(find.widgetWithText(AppButton, 'Выплатить'));
    await tester.pumpAndSettle();
    final body =
        jsonDecode(backend.calls('POST', '/api/payroll').single.body)
            as Map<String, dynamic>;
    expect(body['method'], 'BANK_TRANSFER');
  });

  test('one record by id: sale, employee, payment', () async {
    final backend = FakeBackend()
      ..json(
        'GET',
        '/api/sales/44444444-4444-4444-4444-444444444444',
        ApiJson.sale(),
      )
      ..json(
        'GET',
        '/api/employees/55555555-5555-5555-5555-555555555555',
        ApiJson.employee(),
      )
      ..json('GET', '/api/payroll/66666666-6666-6666-6666-666666666666', {
        ...ApiJson.payment(),
        'method': 'CASH',
      });
    final api = ApiClient(
      tokens: MemoryTokenStorage(accessToken: 'a'),
      client: backend.client,
    );
    expect(
      (await SalesService(
        api,
      ).get('44444444-4444-4444-4444-444444444444')).amount,
      1250.5,
    );
    expect(
      (await EmployeeService(
        api,
      ).get('55555555-5555-5555-5555-555555555555')).id,
      '55555555-5555-5555-5555-555555555555',
    );
    final payment = await PayrollService(
      api,
    ).payment('66666666-6666-6666-6666-666666666666');
    expect(payment.method, SalaryPaymentMethod.cash);
  });
}
