import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/fake_file_share_service.dart';
import '../helpers/memory_statement_history_storage.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('История → Выписка: the list, a cash statement, Excel, and '
      '"Мои выписки"', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final share = FakeFileShareService();
    final mine = MemoryStatementHistoryStorage();
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json('GET', '/api/reports/profit', ApiJson.profit())
      ..json('GET', '/api/activity', ApiJson.page([ApiJson.activity()]));
    stubHome(backend);
    backend.json(
      'GET',
      '/api/sales',
      ApiJson.page([
        {...ApiJson.sale(), 'paymentMethod': 'CASH'},
      ]),
    );
    await pumpApp(
      tester,
      backend,
      fileShare: share,
      statementHistory: mine,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'История');
    await tapText(tester, 'Выписка');

    expect(find.text('Выписки и справки'), findsOneWidget);
    expect(find.text('Кому должны по зарплате'), findsOneWidget);
    expect(find.text('Наличные'), findsOneWidget);
    expect(find.text('Карта и QR'), findsOneWidget);

    await tapText(tester, 'Наличные');
    expect(find.textContaining('1 250,50 TJS'), findsWidgets);
    await tapText(tester, 'Скачать Excel');
    expect(share.shared.single.$1, endsWith('.xlsx'));
    expect(share.shared.single.$1, contains('cash'));
    expect(share.shared.single.$2, isNotEmpty);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tapText(tester, 'Мои выписки');
    expect(find.textContaining('Наличные'), findsOneWidget);
  });
}
