import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/money_category.dart';
import 'package:subhon_app/models/money_transaction_kind.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/fake_voice_service.dart';
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

  testWidgets('quick entry: said "такси 50 картой" is written as a transport '
      'expense; an unknown word opens the form to choose', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final voice = FakeVoiceService();
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    final personal = MemoryPersonalFinanceStorage();
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
      personal: personal,
      voice: voice,
    );
    await tester.tap(find.byTooltip('Сказать'));
    await tester.pumpAndSettle();
    expect(voice.isListening, isTrue);
    voice.say('такси 50');
    await tester.pumpAndSettle();
    expect(find.text('Транспорт'), findsOneWidget);
    await tapText(tester, 'Записать');
    final t = personal.byUser.values.single.transactions.single;
    expect(t.amount, 50);
    expect(t.category, MoneyCategory.transport);
    expect(t.note, 'Такси');

    await tapText(tester, 'Скажите или напишите: «такси 50»');
    await tester.enterText(find.byType(TextField), 'что-то 70');
    await tester.pumpAndSettle();
    expect(find.text('Категория: выберите в «Изменить»'), findsOneWidget);
    await tapText(tester, 'Изменить');
    expect(find.text('Новый расход'), findsOneWidget);
    expect(find.text('70.00'), findsOneWidget);
  });

  testWidgets('Ещё → Цели накоплений: a new goal, then "Пополнить" moves '
      'money to it and home shows the progress', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final personal = await start(tester, store: false);
    await tapText(tester, 'Ещё');
    await tapText(tester, 'Цели накоплений');
    await tapText(tester, 'Новая цель');
    await tester.enterText(fieldWithLabel('На что копим'), 'Машина');
    await tester.enterText(fieldWithLabel('Сколько нужно'), '1000');
    await tapText(tester, 'Сохранить');
    expect(find.text('Машина'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);

    // Some money in the wallet first.
    final vmData = personal.byUser.values.single;
    expect(vmData.goals.single.name, 'Машина');

    await tapText(tester, 'Пополнить');
    expect(find.text('Перевод между счетами'), findsOneWidget);
    await tester.enterText(fieldWithLabel('Сумма'), '250');
    await tapText(tester, 'Сохранить');
    expect(find.text('25%'), findsOneWidget);
    final data = personal.byUser.values.single;
    final t = data.transactions.single;
    expect(t.kind, MoneyTransactionKind.transfer);
    expect(t.toAccountId, data.goals.single.accountId);
    expect(t.accountId, isNot(data.goals.single.accountId));
  });
}
