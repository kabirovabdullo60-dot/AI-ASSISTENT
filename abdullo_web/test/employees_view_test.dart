import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('employees at ${width.toInt()}px: list + add', (tester) async {
      final backend = await pumpApp(tester, width);
      await openSection(tester, AppSection.employees);
      await scrollTo(tester, find.text('Davron Aliev'));
      await scrollToTop(tester);
      await tester.tap(find.byKey(const Key('add-employee')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('employee-name')), 'Nigora Umarova');
      await tester.enterText(find.byKey(const Key('employee-position')), 'Supervisor');
      await tester.enterText(find.byKey(const Key('employee-salary')), '3800');
      await tester.tap(find.byKey(const Key('employee-save')));
      await tester.pumpAndSettle();
      expect(backend.employees.last['fullName'], 'Nigora Umarova');
      expect(backend.employees.last['monthlySalary'], '3800.00');
      await scrollTo(tester, find.text('Nigora Umarova'));
    });
  }

  testWidgets('edit and delete an employee', (tester) async {
    final backend = await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.employees);
    await scrollTo(tester, find.byKey(const Key('edit-employee-e2')));
    await tester.tap(find.byKey(const Key('edit-employee-e2')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('employee-salary')), '3500');
    await tester.tap(find.byKey(const Key('employee-save')));
    await tester.pumpAndSettle();
    expect(backend.employees.firstWhere((e) => e['id'] == 'e2')['monthlySalary'], '3500.00');

    await scrollTo(tester, find.byKey(const Key('delete-employee-e2')));
    await tester.tap(find.byKey(const Key('delete-employee-e2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-employee')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('edit-employee-e2')), findsNothing);
  });
}
