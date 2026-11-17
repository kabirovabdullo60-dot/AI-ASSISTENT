import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('stores at $w: KPIs, cards, filters, regional + log', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.stores);
      expect(find.text('6 Locations'), findsOneWidget);
      expect(find.text('1,089,500'), findsOneWidget);
      expect(find.text('31 Active'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('store-search')), 'khujand');
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(const Key('store-card-s5')));
      expect(find.byKey(const Key('store-card-s1')), findsNothing);

      await scrollTo(tester, find.text('Regional Sales Distribution'));
      await scrollTo(tester, find.text('Store Operations Log'));
    });

    testWidgets('stores at $w: View Analytics opens the side panel', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.stores);
      await scrollTo(tester, find.byKey(const Key('analytics-s1')));
      await tester.tap(find.byKey(const Key('analytics-s1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('store-detail')), findsOneWidget);
      expect(find.text('7-Day Sales Velocity'), findsOneWidget);
      expect(find.text('9 Active Crew'), findsOneWidget);
      await tester.tap(find.byKey(const Key('close-detail')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('store-detail')), findsNothing);
    });
  }

  testWidgets('all store cards are listed', (tester) async {
    await pumpAt(tester, mobileWidth);
    await openSection(tester, AppSection.stores);
    for (final id in ['s1', 's2', 's3', 's4', 's5', 's6']) {
      await scrollTo(tester, find.byKey(Key('store-card-$id')));
    }
  });

  testWidgets('status filter + list view', (tester) async {
    await pumpAt(tester, desktopWidth);
    await openSection(tester, AppSection.stores);
    await tester.tap(find.byKey(const Key('store-status-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inactive').last);
    await tester.pumpAndSettle();
    await scrollTo(tester, find.byKey(const Key('store-card-s6')));
    expect(find.byKey(const Key('store-card-s1')), findsNothing);

    await tester.tap(find.byKey(const Key('list-view')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stores-list')), findsOneWidget);
  });

  testWidgets('add, edit and delete a store', (tester) async {
    await pumpAt(tester, desktopWidth);
    await openSection(tester, AppSection.stores);

    await tester.tap(find.byKey(const Key('add-store')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('store-name')), 'Hisor Fresh Market');
    await tester.enterText(find.byKey(const Key('store-address')), '5 Ayni St');
    await tester.enterText(find.byKey(const Key('store-phone')), '+992 90 555 1122');
    await tester.tap(find.byKey(const Key('store-save')));
    await tester.pumpAndSettle();
    expect(find.text('7 Locations'), findsOneWidget);

    await scrollTo(tester, find.byKey(const Key('edit-s5')));
    await tester.tap(find.byKey(const Key('edit-s5')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('store-name')), 'Khujand Grand Market');
    await tester.tap(find.byKey(const Key('store-save')));
    await tester.pumpAndSettle();
    expect(find.text('Khujand Grand Market'), findsOneWidget);

    await scrollTo(tester, find.byKey(const Key('delete-s6')));
    await tester.tap(find.byKey(const Key('delete-s6')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('store-card-s6')), findsNothing);
  });
}
