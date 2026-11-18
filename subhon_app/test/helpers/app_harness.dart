import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/main.dart';

import 'fake_backend.dart';
import 'memory_locale_storage.dart';
import 'memory_token_storage.dart';

/// Routes a signed-in user's first screens need.
void stubHome(FakeBackend backend) {
  backend
    ..json('GET', '/api/reports/dashboard', ApiJson.dashboard())
    ..json('GET', '/api/sales/daily', ApiJson.salesReport())
    ..json('GET', '/api/reports/store-comparison', ApiJson.storeComparison())
    ..json('GET', '/api/stores', ApiJson.page([ApiJson.store()]))
    ..json(
      'GET',
      '/api/sales',
      ApiJson.page([ApiJson.sale()], totalAmount: '1250.50'),
    )
    ..json('GET', '/api/payroll/monthly', ApiJson.monthlyPayroll());
}

/// The whole app against [backend], in [locale].
Future<void> pumpApp(
  WidgetTester tester,
  FakeBackend backend, {
  MemoryTokenStorage? tokens,
  Locale locale = const Locale('ru'),
}) async {
  await tester.pumpWidget(
    MobileApp(
      httpClient: backend.client,
      tokens: tokens ?? MemoryTokenStorage(),
      localeStorage: MemoryLocaleStorage(),
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text).last;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The editable text of the field labelled [label].
Finder fieldWithLabel(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(EditableText),
);
