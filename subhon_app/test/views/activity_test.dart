import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/l10n/activity_text.dart';
import 'package:subhon_app/l10n/generated/app_localizations_ru.dart';
import 'package:subhon_app/models/activity_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('sentences are built from type + action', () {
    final l10n = AppLocalizationsRu();
    String text(Map<String, Object?> json) =>
        activityText(l10n, ActivityModel.fromJson(json));
    expect(text(ApiJson.activity()), 'Продажа в «Бахор — Сомони»');
    expect(
      text(
        ApiJson.activity(
          type: 'STORE',
          action: 'STATUS_CHANGED',
          status: 'INACTIVE',
          amount: null,
        ),
      ),
      'Магазин «Бахор — Сомони»: Не работает',
    );
    expect(
      text(
        ApiJson.activity(
          type: 'PAYROLL',
          action: 'PAID',
          entityName: 'Шерзод Рахимов',
          amount: '-3000.00',
        ),
      ),
      'Выплачена зарплата: Шерзод Рахимов',
    );
    expect(
      text(ApiJson.activity(type: 'PROFILE', action: 'UPDATED', amount: null)),
      'Профиль изменён',
    );
    // A code the app does not know yet still gives a sentence.
    expect(
      text(ApiJson.activity(type: 'NEW_THING', action: 'CREATED')),
      'Бахор — Сомони: изменение',
    );
  });

  testWidgets('home shows the latest changes; "Все" opens the whole log', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json(
        'GET',
        '/api/activity',
        ApiJson.page([
          ApiJson.activity(),
          ApiJson.activity(
            type: 'PAYROLL',
            action: 'CANCELLED',
            entityName: 'Шерзод Рахимов',
            amount: '-3000.00',
          ),
        ], pages: 2),
      );
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    expect(find.text('Последние действия'), findsOneWidget);
    expect(find.text('Продажа в «Бахор — Сомони»'), findsOneWidget);
    expect(find.text('Отменена выплата: Шерзод Рахимов'), findsOneWidget);
    expect(find.textContaining('Фарход Назаров'), findsWidgets);
    expect(
      backend.calls('GET', '/api/activity').first.url.queryParameters['limit'],
      '5',
    );

    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: find.text('Последние действия'),
          matching: find.byType(Row),
        ),
        matching: find.byType(TextButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Показать ещё'), findsOneWidget);
  });

  testWidgets('without the activity log the dashboard still shows', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend); // no /api/activity route: 404
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    expect(find.text('Продажи за сегодня'), findsOneWidget);
    expect(find.text('Последние действия'), findsNothing);
  });

  testWidgets('the history icon on home opens the whole log', (tester) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json('GET', '/api/activity', ApiJson.page([ApiJson.activity()]));
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tester.tap(find.byTooltip('История'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'История'), findsOneWidget);
    expect(find.text('Продажа в «Бахор — Сомони»'), findsOneWidget);
  });
}
