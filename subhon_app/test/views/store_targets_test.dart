import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

const _storeId = '33333333-3333-3333-3333-333333333333';

Map<String, Object?> _reportWithStore(String total) => {
  ...ApiJson.salesReport(total: total),
  'stores': [
    {
      'storeId': _storeId,
      'storeName': 'Бахор — Сомони',
      'status': 'ACTIVE',
      'isDeleted': false,
      'totalAmount': total,
      'salesCount': 10,
      'averageSaleAmount': '100.00',
      'sharePercent': 100,
      'previousTotalAmount': '0.00',
      'previousSalesCount': 0,
      'changeAmount': total,
      'changePercent': null,
    },
  ],
};

Map<String, Object?> _target(String period, String amount) => {
  'id': '99999999-9999-9999-9999-99999999999${period == 'WEEK' ? 1 : 2}',
  'period': period,
  'storeId': _storeId,
  'storeName': 'Бахор — Сомони',
  'amount': amount,
  'createdAt': '2026-11-18T06:00:00Z',
  'updatedAt': '2026-11-18T06:00:00Z',
};

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('a store shows its own targets; a weekly one is set with its '
      'storeId', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    var targets = <Object?>[_target('MONTH', '90000.00')];
    backend
      ..json('GET', '/api/stores/$_storeId', ApiJson.store())
      ..json('GET', '/api/sales/store/$_storeId', ApiJson.page([]))
      ..json('GET', '/api/employees/store/$_storeId', ApiJson.page([]))
      ..json('GET', '/api/sales/weekly', _reportWithStore('21000.00'))
      ..json('GET', '/api/reports/monthly-sales', _reportWithStore('80000.00'))
      ..on(
        'GET',
        '/api/targets',
        (_) => FakeBackend.respond(ApiJson.page(targets)),
      )
      ..on('PUT', '/api/targets', (request) {
        targets = [...targets, _target('WEEK', '25000.00')];
        return FakeBackend.respond(_target('WEEK', '25000.00'));
      });
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Ещё');
    await tapText(tester, 'Магазины');
    await tapText(tester, 'Бахор — Сомони');

    expect(find.text('Цели магазина'), findsOneWidget);
    expect(find.textContaining('80 000 TJS / 90 000 TJS'), findsOneWidget);
    await tapText(tester, 'Задать цель');
    expect(
      find.text('Только для этого магазина. Можно изменить в любой момент.'),
      findsOneWidget,
    );
    await tester.enterText(fieldWithLabel('Сумма'), '25000');
    await tapText(tester, 'Сохранить');

    final body =
        jsonDecode(backend.calls('PUT', '/api/targets').single.body)
            as Map<String, dynamic>;
    expect(body, {'period': 'WEEK', 'storeId': _storeId, 'amount': '25000.00'});
    expect(find.textContaining('21 000 TJS / 25 000 TJS'), findsOneWidget);
  });
}
