import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('expenses at $w: add → POST /api/expenses → profit drops', (tester) async {
      final backend = await pumpApp(tester, width);
      await openSection(tester, AppSection.expenses);
      expect(find.text('No expenses yet'), findsOneWidget);
      expect(backend.requests, contains('GET /api/reports/profit'));

      await tester.tap(find.byKey(const Key('add-expense')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('expense-amount')), '400');
      await tester.enterText(find.byKey(const Key('expense-description')), 'November rent');
      await tester.tap(find.byKey(const Key('expense-save')));
      await tester.pumpAndSettle();

      expect(backend.requests, contains('POST /api/expenses'));
      expect(backend.expenses.single['category'], 'RENT');
      expect(backend.expenses.single['storeId'], isNull);
      expect(backend.expenses.single['amount'], '400.00');
      expect(find.byType(Dialog), findsNothing);
      await scrollTo(tester, find.text('November rent'));
      expect(find.text('Whole business'), findsWidgets);
    });
  }

  testWidgets('edit and delete an expense (PUT / DELETE /api/expenses/{id})', (tester) async {
    final backend = setUpBackend()
      ..expenses.add({
        'id': 'x1',
        'storeId': null,
        'storeName': null,
        'category': 'DELIVERY',
        'amount': '120.00',
        'expenseDate': FakeBackend.day(DateTime.now()),
        'description': 'Courier',
        'createdAt': '2026-11-18T08:00:00Z',
        'updatedAt': '2026-11-18T08:00:00Z',
      });
    await pumpApp(tester, desktopWidth, backend: backend);
    await openSection(tester, AppSection.expenses);
    expect(find.text('Courier'), findsOneWidget);
    expect(find.text('Delivery'), findsWidgets);

    await tester.tap(find.byKey(const Key('edit-expense-x1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('expense-amount')), '150');
    await tester.tap(find.byKey(const Key('expense-save')));
    await tester.pumpAndSettle();
    expect(backend.requests, contains('PUT /api/expenses/x1'));
    expect(backend.expenses.single['amount'], '150.00');

    await tester.tap(find.byKey(const Key('delete-expense-x1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-expense')));
    await tester.pumpAndSettle();
    expect(backend.requests, contains('DELETE /api/expenses/x1'));
    expect(find.text('No expenses yet'), findsOneWidget);
  });
}
