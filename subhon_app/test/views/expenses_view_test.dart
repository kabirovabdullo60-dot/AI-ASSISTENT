import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

Future<FakeBackend> _openExpenses(
  WidgetTester tester, {
  List<Object?> expenses = const [],
  String total = '0.00',
}) async {
  final backend = FakeBackend()
    ..json('GET', '/api/auth/me', ApiJson.profile())
    ..json('GET', '/api/expenses', ApiJson.page(expenses, totalAmount: total));
  stubHome(backend);
  await pumpApp(
    tester,
    backend,
    tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
  );
  await tapText(tester, 'Ещё');
  await tapText(tester, 'Расходы');
  return backend;
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('the list: category, store or "whole business", the total', (
    tester,
  ) async {
    await _openExpenses(
      tester,
      expenses: [
        ApiJson.expense(),
        ApiJson.expense(
          id: '55555555-5555-5555-5555-555555555556',
          category: 'UTILITIES',
          amount: '450.00',
          storeId: '33333333-3333-3333-3333-333333333333',
          storeName: 'Бахор — Сомони',
          description: null,
        ),
      ],
      total: '3450.00',
    );
    expect(find.text('Сумма расходов'), findsOneWidget);
    expect(find.textContaining('3 450'), findsOneWidget);
    expect(find.text('Аренда'), findsOneWidget);
    expect(find.text('Коммунальные услуги'), findsOneWidget);
    expect(find.textContaining('Весь бизнес'), findsOneWidget);
    expect(find.textContaining('Бахор — Сомони'), findsWidgets);
  });

  testWidgets('filtering by category sends ?category=', (tester) async {
    final backend = await _openExpenses(
      tester,
      expenses: [ApiJson.expense()],
      total: '3000.00',
    );
    await tapText(tester, 'Все категории');
    await tapText(tester, 'Налоги');
    expect(
      backend
          .calls('GET', '/api/expenses')
          .last
          .url
          .queryParameters['category'],
      'TAXES',
    );
  });

  testWidgets('a new expense of the whole business: POST with storeId null', (
    tester,
  ) async {
    final backend = await _openExpenses(tester);
    backend.json('POST', '/api/expenses', ApiJson.expense(), status: 201);
    await tester.tap(find.byTooltip('Расход'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Категория');
    await tapText(tester, 'Аренда');
    await tester.enterText(fieldWithLabel('Сумма'), '3000,5');
    await tester.enterText(fieldWithLabel('Описание'), ' Аренда ');
    await tapText(tester, 'Сохранить');
    final body =
        jsonDecode(backend.calls('POST', '/api/expenses').single.body)
            as Map<String, dynamic>;
    expect(body['category'], 'RENT');
    expect(body['amount'], '3000.50');
    expect(body.containsKey('storeId'), isTrue);
    expect(body['storeId'], isNull);
    expect(body['description'], 'Аренда');
    expect(find.text('Расход добавлен'), findsOneWidget);
  });

  testWidgets('a future date: the translated reason is shown', (tester) async {
    final backend = await _openExpenses(tester);
    backend.on(
      'POST',
      '/api/expenses',
      (_) => FakeBackend.error(422, 'EXPENSE_DATE_IN_FUTURE', 'x'),
    );
    await tester.tap(find.byTooltip('Расход'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Категория');
    await tapText(tester, 'Другое');
    await tester.enterText(fieldWithLabel('Сумма'), '10');
    await tapText(tester, 'Сохранить');
    expect(find.text('Дата расхода не может быть в будущем.'), findsOneWidget);
  });
}
