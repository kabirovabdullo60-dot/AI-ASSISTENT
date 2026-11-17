import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('salaries at $w: KPIs, table, record a payment', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.salaries);
      expect(find.text('Salaries & Payroll Management'), findsOneWidget);
      expect(find.text('7,200'), findsOneWidget); // outstanding
      expect(find.text('14 Employees'), findsOneWidget);

      await scrollTo(tester, find.byKey(const Key('pay-p3')));
      await tester.tap(find.byKey(const Key('pay-p3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('payment-save'))); // pays remaining 1,000
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key('payroll-table')), const Offset(0, 3000));
      await tester.pumpAndSettle();
      expect(find.text('6,200'), findsOneWidget);

      await scrollTo(tester, find.text('Store Budget Allocation'));
      await scrollTo(tester, find.byKey(const Key('disbursements')));
    });
  }

  testWidgets('tabs filter by status; previous month is fully paid', (tester) async {
    await pumpAt(tester, desktopWidth);
    await openSection(tester, AppSection.salaries);
    await tester.tap(find.text('Unpaid (2)'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pay-p6')), findsOneWidget);
    expect(find.byKey(const Key('pay-p3')), findsNothing);

    await tester.tap(find.byKey(const Key('prev-month')));
    await tester.pumpAndSettle();
    expect(find.text('Unpaid (0)'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('History dialog lists payments', (tester) async {
    await pumpAt(tester, desktopWidth);
    await openSection(tester, AppSection.salaries);
    await scrollTo(tester, find.byKey(const Key('history-p1')));
    await tester.tap(find.byKey(const Key('history-p1')));
    await tester.pumpAndSettle();
    expect(find.text('+4,500 TJS'), findsWidgets);
  });

  testWidgets('Record Salary Payment button: choose employee', (tester) async {
    await pumpAt(tester, desktopWidth);
    await openSection(tester, AppSection.salaries);
    await tester.tap(find.byKey(const Key('record-salary')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('payment-employee')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('payment-amount')), '500');
    await tester.tap(find.byKey(const Key('payment-save')));
    await tester.pumpAndSettle();
    expect(find.text('6,700'), findsOneWidget);
  });
}
