import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:subhon_app/views/auth_view.dart';
import 'package:subhon_app/views/shell_view.dart';
import 'package:subhon_app/widgets/app_button.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

Future<void> _signIn(WidgetTester tester, String password) async {
  await tester.enterText(fieldWithLabel('E-mail'), 'farhod@bahor.tj');
  await tester.enterText(fieldWithLabel('Пароль'), password);
  await tester.tap(find.widgetWithText(AppButton, 'Войти'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('wrong password: the translated reason is shown, not the '
      'server text', (tester) async {
    final backend = FakeBackend()
      ..on(
        'POST',
        '/api/auth/login',
        (_) => FakeBackend.error(
          401,
          'AUTH_INVALID_CREDENTIALS',
          'Email or password is incorrect.',
        ),
      );
    await pumpApp(tester, backend);
    await _signIn(tester, 'wrong');
    expect(find.text('Неверный e-mail или пароль.'), findsOneWidget);
    expect(find.text('Email or password is incorrect.'), findsNothing);
    expect(find.byType(AuthView), findsOneWidget);
  });

  testWidgets('the same error in English', (tester) async {
    final backend = FakeBackend()
      ..on(
        'POST',
        '/api/auth/login',
        (_) => FakeBackend.error(401, 'AUTH_INVALID_CREDENTIALS', 'x'),
      );
    await pumpApp(tester, backend, locale: const Locale('en'));
    await tester.enterText(fieldWithLabel('E-mail'), 'farhod@bahor.tj');
    await tester.enterText(fieldWithLabel('Password'), 'wrong');
    await tester.tap(find.widgetWithText(AppButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Wrong e-mail or password.'), findsOneWidget);
    expect(backend.requests.single.headers['Accept-Language'], 'en');
  });

  testWidgets('successful login opens the app with the dashboard from the '
      'API; both tokens are saved', (tester) async {
    final tokens = MemoryTokenStorage();
    final backend = FakeBackend()
      ..json('POST', '/api/auth/login', ApiJson.auth());
    stubHome(backend);
    await pumpApp(tester, backend, tokens: tokens);
    await _signIn(tester, 'Ofar2026');
    expect(find.byType(ShellView), findsOneWidget);
    await openBusiness(tester);
    expect(find.text('Продажи за сегодня'), findsOneWidget);
    expect(find.text('112\u00a0028 TJS'), findsOneWidget);
    expect(find.text('6\u00a0940,50 TJS'), findsWidgets);
    expect(tokens.accessToken, 'access-1');
    expect(tokens.refreshToken, 'refresh-1');
    expect(
      backend
          .calls('GET', '/api/reports/dashboard')
          .single
          .headers['Authorization'],
      'Bearer access-1',
    );
  });

  testWidgets('a saved session is restored with GET /api/auth/me', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    expect(find.byType(ShellView), findsOneWidget);
    expect(backend.calls('GET', '/api/auth/me'), hasLength(1));
  });

  testWidgets('the session is revoked while using the app: back to the login '
      'screen, tokens cleared', (tester) async {
    final tokens = MemoryTokenStorage(accessToken: 'a', refreshToken: 'r');
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    backend.on(
      'GET',
      '/api/reports/dashboard',
      (_) => FakeBackend.error(401, 'AUTH_SESSION_REVOKED', 'Revoked.'),
    );
    await pumpApp(tester, backend, tokens: tokens);
    expect(find.byType(AuthView), findsOneWidget);
    expect(tokens.refreshToken, isNull);
  });

  testWidgets('no connection: the error state with "Повторить" works', (
    tester,
  ) async {
    var online = false;
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    backend
      ..json('GET', '/api/reports/profit', ApiJson.profit())
      ..json('GET', '/api/reports/payroll', ApiJson.payrollYear())
      ..on('GET', '/api/reports/employees', (_) {
        if (!online) throw http.ClientException('offline');
        return FakeBackend.respond(ApiJson.employeesReport());
      });
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Ещё');
    await tapText(tester, 'Отчёты');
    expect(find.text('Не удалось загрузить'), findsOneWidget);
    online = true;
    await tapText(tester, 'Повторить');
    expect(find.text('Прибыль'), findsWidgets);
  });

  testWidgets('salary payment: open the month, pay the remaining amount; the '
      'month reloads', (tester) async {
    // A tall screen: the whole payment form is built.
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    var paid = false;
    backend.on(
      'GET',
      '/api/payroll/monthly',
      (_) => FakeBackend.respond(
        ApiJson.monthlyPayroll(status: paid ? 'PAID' : 'PARTIAL'),
      ),
    );
    backend.on('POST', '/api/payroll', (_) {
      paid = true;
      return FakeBackend.respond(ApiJson.payment(), status: 201);
    });
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await openPayroll(tester);
    expect(find.text('Частично'), findsWidgets);
    await tapText(tester, 'Шерзод Рахимов');
    expect(find.text('Выплата зарплаты'), findsOneWidget);
    await tester.tap(find.widgetWithText(AppButton, 'Выплатить'));
    await tester.pumpAndSettle();
    final body =
        jsonDecode(backend.calls('POST', '/api/payroll').single.body)
            as Map<String, dynamic>;
    expect(body['employeeId'], '55555555-5555-5555-5555-555555555555');
    expect(body['amount'], '2000.00');
    expect(body['month'], isA<int>());
    expect(find.text('Выплата записана'), findsOneWidget);
    expect(find.text('Выплачено'), findsWidgets);
  });

  testWidgets('deleting a store with working employees: the reason is shown', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    final store = ApiJson.store();
    final id = store['id']! as String;
    backend
      ..json('GET', '/api/stores/$id', store)
      ..json('GET', '/api/sales/store/$id', ApiJson.page([]))
      ..json('GET', '/api/employees/store/$id', ApiJson.page([]))
      ..on(
        'DELETE',
        '/api/stores/$id',
        (_) => FakeBackend.error(409, 'STORE_HAS_ACTIVE_EMPLOYEES', 'x'),
      );
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Ещё');
    await tapText(tester, 'Магазины');
    await tapText(tester, 'Бахор — Сомони');
    await tester.tap(find.byTooltip('Удалить'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Удалить'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('В магазине есть работающие сотрудники'),
      findsOneWidget,
    );
  });
}
