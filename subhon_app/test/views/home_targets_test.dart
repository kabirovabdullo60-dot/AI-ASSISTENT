import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('home shows the month profit and the targets; a weekly target '
      'is set with PUT /api/targets', (tester) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    backend.on('PUT', '/api/targets', (request) {
      backend.json(
        'GET',
        '/api/reports/dashboard',
        ApiJson.dashboard(weekTarget: '30000.00'),
      );
      return FakeBackend.respond({
        'id': '66666666-6666-6666-6666-666666666666',
        'period': 'WEEK',
        'storeId': null,
        'storeName': null,
        'amount': '30000.00',
        'createdAt': '2026-11-18T06:00:00Z',
        'updatedAt': '2026-11-18T06:00:00Z',
      });
    });
    // A tall screen, so the whole home list is built.
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );

    expect(find.text('Прибыль за месяц'), findsOneWidget);
    expect(find.textContaining('82 028'), findsOneWidget);
    // The monthly target is set: progress against it.
    expect(find.textContaining('150 000'), findsOneWidget);
    // The weekly one is not.
    await tapText(tester, 'Задать цель');
    await tester.enterText(fieldWithLabel('Сумма'), '30000');
    await tapText(tester, 'Сохранить');

    final body =
        jsonDecode(backend.calls('PUT', '/api/targets').single.body)
            as Map<String, dynamic>;
    expect(body, {'period': 'WEEK', 'storeId': null, 'amount': '30000.00'});
    expect(find.text('Цель сохранена'), findsOneWidget);
    expect(find.text('Задать цель'), findsNothing);
    expect(find.textContaining('30 000'), findsWidgets);
  });
}
