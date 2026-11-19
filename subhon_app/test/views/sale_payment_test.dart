import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/payment_method.dart';
import 'package:subhon_app/models/sale_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

Future<FakeBackend> _openNewSale(WidgetTester tester) async {
  // A tall screen: the whole form is built.
  await tester.binding.setSurfaceSize(const Size(800, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final backend = FakeBackend()..json('GET', '/api/auth/me', ApiJson.profile());
  stubHome(backend);
  backend.json('POST', '/api/sales', ApiJson.sale(), status: 201);
  await pumpApp(
    tester,
    backend,
    tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
  );
  // The sales list opens from "+".
  await tester.tap(find.byTooltip('Добавить'));
  await tester.pumpAndSettle();
  await tapText(tester, 'Продажи');
  await tester.tap(find.byTooltip('Продажа'));
  await tester.pumpAndSettle();
  await tapText(tester, 'Выберите магазин');
  await tapText(tester, 'Бахор — Сомони');
  return backend;
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('a sale is read with its payment method and split', () {
    final sale = SaleModel.fromJson({
      ...ApiJson.sale(),
      'paymentMethod': 'MIXED',
      'cashAmount': '250.50',
      'cardAmount': '1000.00',
      'receiptNumber': 'A-17',
      'registeredByName': 'Фарход Назаров',
    });
    expect(sale.paymentMethod, PaymentMethod.mixed);
    expect(sale.cashAmount, 250.5);
    expect(sale.cardAmount, 1000);
    expect(sale.receiptNumber, 'A-17');
    // Old records without these fields still read.
    expect(SaleModel.fromJson(ApiJson.sale()).paymentMethod, isNull);
  });

  testWidgets('cash + card: the split is sent with the method and receipt', (
    tester,
  ) async {
    final backend = await _openNewSale(tester);
    await tester.enterText(fieldWithLabel('Сумма'), '1250,50');
    await tapText(tester, 'Не указан');
    await tapText(tester, 'Наличные + карта');
    await tester.enterText(fieldWithLabel('Из них наличными'), '250,50');
    await tester.enterText(fieldWithLabel('Из них картой'), '1000');
    await tester.enterText(fieldWithLabel('Номер чека'), ' A-17 ');
    await tapText(tester, 'Сохранить');
    final body =
        jsonDecode(backend.calls('POST', '/api/sales').single.body)
            as Map<String, dynamic>;
    expect(body['paymentMethod'], 'MIXED');
    expect(body['cashAmount'], '250.50');
    expect(body['cardAmount'], '1000.00');
    expect(body['receiptNumber'], 'A-17');
  });

  testWidgets('a split that does not add up is not sent', (tester) async {
    final backend = await _openNewSale(tester);
    await tester.enterText(fieldWithLabel('Сумма'), '1000');
    await tapText(tester, 'Не указан');
    await tapText(tester, 'Наличные + карта');
    await tester.enterText(fieldWithLabel('Из них наличными'), '300');
    await tester.enterText(fieldWithLabel('Из них картой'), '300');
    await tapText(tester, 'Сохранить');
    expect(
      find.text('Наличные и карта вместе должны равняться сумме'),
      findsWidgets,
    );
    expect(backend.calls('POST', '/api/sales'), isEmpty);
  });

  testWidgets('card only: no split fields, the method is sent', (tester) async {
    final backend = await _openNewSale(tester);
    await tester.enterText(fieldWithLabel('Сумма'), '99');
    await tapText(tester, 'Не указан');
    await tapText(tester, 'Карта');
    expect(find.text('Из них наличными'), findsNothing);
    await tapText(tester, 'Сохранить');
    final body =
        jsonDecode(backend.calls('POST', '/api/sales').single.body)
            as Map<String, dynamic>;
    expect(body['paymentMethod'], 'CARD');
    expect(body.containsKey('cashAmount'), isFalse);
  });
}
