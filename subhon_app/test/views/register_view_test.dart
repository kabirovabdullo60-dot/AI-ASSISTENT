import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/views/shell_view.dart';
import 'package:subhon_app/widgets/jelly_blob.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';

Future<void> _openRegister(WidgetTester tester, FakeBackend backend) async {
  await pumpApp(tester, backend);
  await tapText(tester, 'Зарегистрироваться');
}

Future<void> _fill(WidgetTester tester, {required String password}) async {
  await tester.enterText(fieldWithLabel('Имя и фамилия'), ' Фарход Назаров ');
  await tester.enterText(fieldWithLabel('Рабочий e-mail'), 'farhod@bahor.tj');
  await tester.enterText(fieldWithLabel('Пароль'), password);
  await tapText(tester, 'Зарегистрироваться');
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('the new design: mascot, texts, 3 fields', (tester) async {
    await _openRegister(tester, FakeBackend());
    expect(find.byType(JellyBlob), findsOneWidget);
    expect(find.text('Создайте аккаунт'), findsOneWidget);
    expect(
      find.text('ИИ-бухгалтер для учёта доходов и расходов'),
      findsOneWidget,
    );
    expect(find.text('Рабочий e-mail'), findsOneWidget);
    expect(find.text('Минимум 8 символов'), findsOneWidget); // the hint
    expect(find.text('Уже есть аккаунт?'), findsOneWidget);
    expect(find.byType(EditableText), findsNWidgets(3));
  });

  testWidgets('a password under 8 characters is not sent', (tester) async {
    final backend = FakeBackend();
    await _openRegister(tester, backend);
    await _fill(tester, password: 'short');
    expect(find.text('Минимум 8 символов'), findsWidgets);
    expect(backend.calls('POST', '/api/auth/register'), isEmpty);
  });

  testWidgets('registers with name, e-mail and password and opens the app', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..json('POST', '/api/auth/register', ApiJson.auth(), status: 201);
    stubHome(backend);
    await _openRegister(tester, backend);
    await _fill(tester, password: 'Ofar2026!');
    final body =
        jsonDecode(backend.calls('POST', '/api/auth/register').single.body)
            as Map<String, dynamic>;
    expect(body['fullName'], 'Фарход Назаров');
    expect(body['email'], 'farhod@bahor.tj');
    expect(body['password'], 'Ofar2026!');
    expect(body['phone'], isNull);
    expect(body['businessName'], isNull);
    expect(find.byType(ShellView), findsOneWidget);
  });
}
