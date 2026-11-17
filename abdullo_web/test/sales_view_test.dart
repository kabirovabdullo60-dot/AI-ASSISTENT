import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('sales at $w: totals, form, today table', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.sales);
      expect(find.text('Sales & Daily Entries'), findsOneWidget);
      expect(find.text('New Daily Sales Record'), findsOneWidget);
      await scrollTo(tester, find.byKey(const Key('sales-table')));
      expect(find.textContaining('across 5 entries', findRichText: true), findsOneWidget);
    });

    testWidgets('sales at $w: saving an entry shows the success banner', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.sales);
      await tester.enterText(find.byKey(const Key('sale-amount')), '5450');
      await scrollTo(tester, find.byKey(const Key('sale-save')));
      await tester.tap(find.byKey(const Key('sale-save')));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(const Key('filtered-total')));
      expect(find.textContaining('42,200 TJS', findRichText: true), findsWidgets); // 36,750 + 5,450
      await tester.drag(find.byKey(const Key('filtered-total')), const Offset(0, 3000));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sale-success')), findsOneWidget);
      await tester.tap(find.byKey(const Key('dismiss-banner')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sale-success')), findsNothing);
    });
  }

  testWidgets('This Month tab + pagination + store filter', (tester) async {
    await pumpAt(tester, desktopWidth);
    await openSection(tester, AppSection.sales);
    await tester.tap(find.byKey(const Key('tab-This Month')));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byKey(const Key('pager-next')));
    await tester.tap(find.byKey(const Key('pager-next')));
    await tester.pumpAndSettle();
    expect(find.textContaining('7–12'), findsOneWidget);

    await scrollTo(tester, find.byKey(const Key('sales-store-filter')));
    await tester.tap(find.byKey(const Key('sales-store-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rudaki Mall Kiosk').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Showing 1–'), findsOneWidget);
  });
}
