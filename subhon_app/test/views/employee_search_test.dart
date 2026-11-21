import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('employees are searched as you type; ✕ clears the search', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json('GET', '/api/reports/employees', ApiJson.employeesReport())
      ..on('GET', '/api/employees', (request) {
        final search = request.url.queryParameters['search'];
        return FakeBackend.respond(
          ApiJson.page(search == 'Мах' ? [] : [ApiJson.employee()]),
        );
      });
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Ещё');
    await tapText(tester, 'Сотрудники');
    expect(find.text('Шерзод Рахимов'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'Мах');
    await tester.pump(const Duration(milliseconds: 100));
    // Still typing: nothing sent yet.
    expect(
      backend
          .calls('GET', '/api/employees')
          .where((r) => r.url.queryParameters['search'] == 'Мах'),
      isEmpty,
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(
      backend.calls('GET', '/api/employees').last.url.queryParameters['search'],
      'Мах',
    );
    expect(find.text('Ничего не найдено.'), findsOneWidget);

    await tester.tap(find.byTooltip('Очистить'));
    await tester.pumpAndSettle();
    expect(
      backend
          .calls('GET', '/api/employees')
          .last
          .url
          .queryParameters
          .containsKey('search'),
      isFalse,
    );
    expect(find.text('Шерзод Рахимов'), findsOneWidget);
  });
}
