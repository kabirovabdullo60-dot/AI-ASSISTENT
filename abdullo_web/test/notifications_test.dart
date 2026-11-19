import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Map<String, dynamic> _notice(String kind, {int count = 1, String? amount, String? store, String link = 'PAYROLL'}) => {
  'id': 'n-$kind',
  'kind': kind,
  'severity': kind == 'SALARY_OVERDUE' ? 'WARNING' : 'INFO',
  'count': count,
  'amount': amount,
  'storeId': store == null ? null : 's1',
  'storeName': store,
  'link': link,
  'read': false,
  'createdAt': '2026-11-01T00:00:00Z',
};

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('bell at ${width.toInt()}px shows GET /api/notifications and marks them read', (tester) async {
      final backend = setUpBackend()
        ..notifications.addAll([
          _notice('SALARY_OVERDUE', count: 3, amount: '9000.00'),
          _notice('STORE_NO_SALES_TODAY', store: 'Central Plaza', link: 'SALES'),
        ]);
      await pumpApp(tester, width, backend: backend);
      expect(
        find.descendant(of: find.byKey(const Key('notifications-badge')), matching: find.text('2')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('notifications')));
      await tester.pumpAndSettle();
      expect(find.text('Overdue salaries: 3 unpaid months · 9,000 TJS'), findsOneWidget);
      expect(find.text('Central Plaza: no sales today'), findsOneWidget);
      expect(backend.requests, contains('POST /api/notifications/read-all'));

      await tester.tap(find.text('Central Plaza: no sales today'));
      await tester.pumpAndSettle();
      expect(find.descendant(of: find.byKey(const Key('notifications-badge')), matching: find.text('2')), findsNothing);
    });
  }

  testWidgets('USD uses the rate from GET /api/settings/exchange-rates', (tester) async {
    final backend = setUpBackend()..usdRate = '15.00';
    await pumpApp(tester, desktopWidth, backend: backend);
    expect(backend.requests, contains('GET /api/settings/exchange-rates'));
    await tester.tap(find.text(r'USD ($)'));
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget); // 1,500 / 15
    await tester.tap(find.text('TJS (Сомонӣ)'));
    await tester.pumpAndSettle();
  });
}
