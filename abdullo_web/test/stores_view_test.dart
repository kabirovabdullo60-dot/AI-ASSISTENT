import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('stores at ${width.toInt()}px: KPIs, cards, search', (tester) async {
      await pumpApp(tester, width);
      await openSection(tester, AppSection.stores);
      expect(find.text('3 stores'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('store-search')), 'somoni');
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(const Key('store-card-s2')));
      expect(find.byKey(const Key('store-card-s1')), findsNothing);
    });

    testWidgets('stores at ${width.toInt()}px: analytics panel loads store sales + staff', (tester) async {
      final backend = await pumpApp(tester, width);
      await openSection(tester, AppSection.stores);
      await scrollTo(tester, find.byKey(const Key('analytics-s1')));
      await tester.tap(find.byKey(const Key('analytics-s1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('store-detail')), findsOneWidget);
      expect(find.text('2 Active Crew'), findsOneWidget);
      expect(backend.requests, contains('GET /api/sales/store/s1'));
      expect(backend.requests, contains('GET /api/employees/store/s1'));
      await tester.tap(find.byKey(const Key('close-detail')));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('add, edit, delete a store (PUT/POST/DELETE /api/stores)', (tester) async {
    final backend = await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.stores);

    await tester.tap(find.byKey(const Key('add-store')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('store-name')), 'Hisor Market');
    await tester.enterText(find.byKey(const Key('store-phone')), '+992 90 555 11 22');
    await tester.tap(find.byKey(const Key('store-save')));
    await tester.pumpAndSettle();
    expect(find.text('4 stores'), findsOneWidget);
    expect(backend.stores.last['phone'], '+992905551122');

    await scrollTo(tester, find.byKey(const Key('edit-s2')));
    await tester.tap(find.byKey(const Key('edit-s2')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('store-name')), 'Somoni Grand');
    await tester.tap(find.byKey(const Key('store-save')));
    await tester.pumpAndSettle();
    expect(backend.stores.firstWhere((s) => s['id'] == 's2')['name'], 'Somoni Grand');

    await scrollTo(tester, find.byKey(const Key('delete-s3')));
    await tester.tap(find.byKey(const Key('delete-s3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('store-card-s3')), findsNothing);
  });

  testWidgets('deleting a store with active staff shows the backend error', (tester) async {
    await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.stores);
    await scrollTo(tester, find.byKey(const Key('delete-s1')));
    await tester.tap(find.byKey(const Key('delete-s1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();
    expect(find.textContaining('still has active employees'), findsOneWidget);
    expect(find.byKey(const Key('store-card-s1')), findsOneWidget);
  });
}
