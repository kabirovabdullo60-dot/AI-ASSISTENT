import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/money_transaction_kind.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_personal_finance_storage.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  Future<MemoryPersonalFinanceStorage> start(
    WidgetTester tester, {
    required bool store,
  }) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    if (!store) backend.json('GET', '/api/stores', ApiJson.page([]));
    final personal = MemoryPersonalFinanceStorage();
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
      personal: personal,
    );
    return personal;
  }

  testWidgets('no store: home is "Мои финансы" with a cash wallet; "+" has '
      'only personal actions; an expense is written and counted', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final personal = await start(tester, store: false);
    expect(find.text('Мои деньги'), findsOneWidget);
    expect(find.text('Наличные'), findsWidgets);
    expect(find.text('Продажи за сегодня'), findsNothing);

    await tester.tap(find.byTooltip('Добавить'));
    await tester.pumpAndSettle();
    expect(find.text('Продажа'), findsNothing);
    expect(find.text('Доход'), findsOneWidget);
    await tapText(tester, 'Расход');

    await tester.enterText(fieldWithLabel('Сумма'), '120');
    await tapText(tester, 'Продукты');
    await tapText(tester, 'Сохранить');

    final data = personal.byUser.values.single;
    final t = data.transactions.single;
    expect(t.kind, MoneyTransactionKind.expense);
    expect(t.amount, 120);
    expect(t.accountId, data.accounts.single.id);
    expect(find.text('Продукты'), findsWidgets);
  });

  testWidgets('with a store: "Мой бизнес" → "Открыть" shows the shop', (
    tester,
  ) async {
    await start(tester, store: true);
    expect(find.text('Мои деньги'), findsOneWidget);
    await openBusiness(tester);
    expect(find.widgetWithText(AppBar, 'Мой бизнес'), findsOneWidget);
    expect(find.text('Продажи за сегодня'), findsOneWidget);
  });
}
