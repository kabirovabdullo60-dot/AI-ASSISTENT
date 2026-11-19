import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('salaries at ${width.toInt()}px: KPIs + pay the rest of a partial salary', (tester) async {
      final backend = await pumpApp(tester, width);
      await openSection(tester, AppSection.salaries);
      expect(find.text('4,200'), findsOneWidget); // remaining this month
      await scrollTo(tester, find.byKey(const Key('pay-e3')));
      await tester.tap(find.byKey(const Key('pay-e3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('payment-save'))); // prefilled with remaining 1,000
      await tester.pumpAndSettle();
      expect(backend.requests, contains('POST /api/payroll'));
      await scrollToTop(tester);
      expect(find.text('3,200'), findsOneWidget);
    });
  }

  testWidgets('amount above the remaining salary is blocked in the form', (tester) async {
    await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.salaries);
    await scrollTo(tester, find.byKey(const Key('pay-e2')));
    await tester.tap(find.byKey(const Key('pay-e2')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('payment-amount')), '9999');
    await tester.tap(find.byKey(const Key('payment-save')));
    await tester.pumpAndSettle();
    expect(find.text('Max 3,200 TJS'), findsOneWidget);
  });

  testWidgets('history dialog: cancel a payment (DELETE /api/payroll/{id})', (tester) async {
    final backend = await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.salaries);
    await scrollTo(tester, find.byKey(const Key('history-e1')));
    await tester.tap(find.byKey(const Key('history-e1')));
    await tester.pumpAndSettle();
    final pay = backend.payments.firstWhere((p) => p['employeeId'] == 'e1');
    await tester.tap(find.byKey(Key('cancel-payment-${pay['id']}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-cancel-payment')));
    await tester.pumpAndSettle();
    expect(pay['deleted'], isTrue);
  });

  testWidgets('tabs filter by status; previous month loads from the API', (tester) async {
    final backend = await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.salaries);
    await tester.tap(find.text('Unpaid (1)'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pay-e2')), findsOneWidget);
    expect(find.byKey(const Key('pay-e3')), findsNothing);
    await tester.tap(find.byKey(const Key('prev-month')));
    await tester.pumpAndSettle();
    expect(backend.requests.where((r) => r == 'GET /api/payroll/monthly').length, greaterThan(1));
  });
}
