import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/widgets/kpi_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('dashboard at ${width.toInt()}px: KPIs, chart, top stores, activity', (tester) async {
      await pumpAt(tester, width);
      expect(find.text('Business Overview'), findsOneWidget);
      expect(find.byType(KpiCard), findsNWidgets(6));
      expect(find.text('36,750'), findsOneWidget); // today = sum of stores
      expect(find.text('7,200'), findsOneWidget); // unpaid salaries
      await scrollTo(tester, find.byKey(const Key('revenue-chart')));
      await scrollTo(tester, find.text('Central Plaza Flagship'));
      await scrollTo(tester, find.text('Recent Business Activity'));
    });
  }

  testWidgets('desktop: 6 KPI cards in one row; mobile: 2 per row', (tester) async {
    await pumpAt(tester, desktopWidth);
    final cards = find.byType(KpiCard);
    expect(tester.getTopLeft(cards.at(0)).dy, tester.getTopLeft(cards.at(5)).dy);

    await pumpAt(tester, mobileWidth);
    expect(tester.getTopLeft(cards.at(0)).dy, tester.getTopLeft(cards.at(1)).dy);
    expect(tester.getTopLeft(cards.at(0)).dy, lessThan(tester.getTopLeft(cards.at(2)).dy));
  });

  testWidgets('hovering the chart shows that day\'s numbers', (tester) async {
    await pumpAt(tester, desktopWidth);
    await scrollTo(tester, find.byKey(const Key('revenue-chart')));
    final chart = find.byKey(const Key('revenue-chart'));
    final box = tester.getRect(chart);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(Offset(box.right - 5, box.center.dy)); // last bar = today
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chart-tooltip')), findsOneWidget);
    expect(find.text('Revenue: 36,750 TJS'), findsOneWidget);
    expect(find.textContaining('Cashflow: '), findsOneWidget);
    await mouse.moveTo(Offset(box.left - 50, box.top - 50));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chart-tooltip')), findsNothing);
  });

  testWidgets('tapping a bar on a phone shows the tooltip', (tester) async {
    await pumpAt(tester, mobileWidth);
    await scrollTo(tester, find.byKey(const Key('revenue-chart')));
    final box = tester.getRect(find.byKey(const Key('revenue-chart')));
    await tester.tapAt(Offset(box.left + 3, box.center.dy));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chart-tooltip')), findsOneWidget);
  });

  testWidgets('USD toggle converts amounts', (tester) async {
    await pumpAt(tester, desktopWidth);
    await tester.tap(find.text(r'USD ($)'));
    await tester.pumpAndSettle();
    expect(find.text('3,356'), findsOneWidget); // 36,750 / 10.95
  });

  testWidgets('Record Sale dialog adds to today and to the activity feed', (tester) async {
    await pumpAt(tester, desktopWidth);
    await tester.tap(find.byKey(const Key('record-sale')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sale-amount')), '1550');
    await tester.tap(find.byKey(const Key('sale-save')));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(find.text('38,300'), findsOneWidget); // 36,750 + 1,550
    await scrollTo(tester, find.textContaining('+1,550 TJS', findRichText: true));
  });

  testWidgets('store selector filters the dashboard to one store', (tester) async {
    await pumpAt(tester, desktopWidth);
    await tester.tap(find.byKey(const Key('store-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rudaki Mall Kiosk').last);
    await tester.pumpAndSettle();
    expect(find.text('6,100'), findsOneWidget); // Rudaki today only
    expect(find.text('All Stores (5 Active)'), findsNothing);
  });

  testWidgets('"View All Stores" opens the Stores page', (tester) async {
    await pumpAt(tester, desktopWidth);
    await scrollTo(tester, find.byKey(const Key('view-all-stores')));
    await tester.tap(find.byKey(const Key('view-all-stores')));
    await tester.pumpAndSettle();
    expect(find.text('Store Management'), findsOneWidget);
    await openSection(tester, AppSection.dashboard);
  });
}
