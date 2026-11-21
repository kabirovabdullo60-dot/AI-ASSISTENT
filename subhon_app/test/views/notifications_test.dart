import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/views/payroll_view.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('the bell shows the unread count; opening the list marks all '
      'read; a salary notification opens the payroll tab', (tester) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json('GET', '/api/notifications', ApiJson.notifications())
      ..on(
        'POST',
        '/api/notifications/read-all',
        (_) => FakeBackend.respond(null, status: 204),
      );
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('2')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Уведомления'));
    await tester.pumpAndSettle();
    expect(find.text('Просроченная зарплата'), findsOneWidget);
    expect(find.textContaining('6 000'), findsOneWidget);
    expect(find.text('Сегодня нет продаж'), findsOneWidget);
    expect(find.textContaining('Бахор — Сомони'), findsOneWidget);
    expect(find.text('Новое'), findsNWidgets(2));
    expect(backend.calls('POST', '/api/notifications/read-all'), hasLength(1));

    await tester.tap(find.text('Просроченная зарплата'));
    await tester.pumpAndSettle();
    expect(find.byType(PayrollView), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('2')),
      findsNothing,
    );
  });

  testWidgets('nothing to show: a calm empty state, no read-all call', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json('GET', '/api/notifications', {
        'items': <Object>[],
        'unreadCount': 0,
        'lastReadAt': null,
      });
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tester.tap(find.byTooltip('Уведомления'));
    await tester.pumpAndSettle();
    expect(
      find.text('Всё в порядке: ничего не требует внимания.'),
      findsOneWidget,
    );
    expect(backend.calls('POST', '/api/notifications/read-all'), isEmpty);
  });
}
