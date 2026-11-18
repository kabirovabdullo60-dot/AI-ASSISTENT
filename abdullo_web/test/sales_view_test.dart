import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('sales at ${width.toInt()}px: save an entry → banner + new total', (tester) async {
      final backend = await pumpApp(tester, width);
      await openSection(tester, AppSection.sales);
      expect(find.text('Sales & Daily Entries'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('sale-amount')), '300');
      await scrollTo(tester, find.byKey(const Key('sale-save')));
      await tester.tap(find.byKey(const Key('sale-save')));
      await tester.pumpAndSettle();
      expect(backend.requests.where((r) => r == 'POST /api/sales'), hasLength(1));
      await scrollTo(tester, find.byKey(const Key('filtered-total')));
      expect(find.textContaining('1,800 TJS', findRichText: true), findsWidgets);
      await scrollToTop(tester);
      expect(find.byKey(const Key('sale-success')), findsOneWidget);
    });
  }

  testWidgets('This Month + server pagination + store filter', (tester) async {
    final backend = await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.sales);
    await tester.tap(find.byKey(const Key('tab-This Month')));
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byKey(const Key('pager-next')));
    await tester.tap(find.byKey(const Key('pager-next')));
    await tester.pumpAndSettle();
    expect(find.textContaining('7–12'), findsOneWidget);
    expect(backend.requests.where((r) => r == 'GET /api/sales').length, greaterThan(2));

    await scrollTo(tester, find.byKey(const Key('sales-store-filter')), delta: -300);
    await tester.tap(find.byKey(const Key('sales-store-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Somoni Branch').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Showing 1–'), findsOneWidget);
  });

  testWidgets('edit and delete a sale (PUT / DELETE /api/sales/{id})', (tester) async {
    final backend = await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.sales);
    final todayS1 = backend.sales.firstWhere(
      (s) => s['storeId'] == 's1' && s['saleDate'] == FakeBackend.day(backend.today),
    );
    final id = todayS1['id'];

    await scrollTo(tester, find.byKey(Key('edit-sale-$id')));
    await tester.tap(find.byKey(Key('edit-sale-$id')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sale-amount')).last, '1200');
    await tester.tap(find.byKey(const Key('sale-save')).last);
    await tester.pumpAndSettle();
    expect(todayS1['amount'], '1200.00');

    await scrollTo(tester, find.byKey(Key('delete-sale-$id')));
    await tester.tap(find.byKey(Key('delete-sale-$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-sale')));
    await tester.pumpAndSettle();
    expect(todayS1['deleted'], isTrue);
  });
}
