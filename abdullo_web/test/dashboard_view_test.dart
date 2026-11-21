import 'package:provider/provider.dart';
import 'package:abdullo_web/viewmodels/dashboard_view_model.dart';
import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/widgets/kpi_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('dashboard at ${width.toInt()}px shows the backend numbers', (tester) async {
      await pumpApp(tester, width);
      // The answer first: today's takings with the chart in the same card.
      expect(find.byKey(const Key('dashboard-hero')), findsOneWidget);
      expect(find.text('1,500'), findsOneWidget); // today 1000 + 500
      expect(find.byKey(const Key('revenue-chart')), findsOneWidget);
      await scrollTo(tester, find.text('4,200')); // unpaid salaries this month
      expect(find.text('4,200'), findsOneWidget);
      expect(find.byType(KpiCard), findsWidgets);
      await scrollTo(tester, find.text('Stores open')); // stores
      await scrollTo(tester, find.text('Central Plaza'));
      await scrollTo(tester, find.byKey(const Key('dashboard-ai')));
      await scrollTo(tester, find.text('Recent Business Activity'));
    });
  }

  testWidgets('hovering the chart shows that day\'s numbers', (tester) async {
    await pumpApp(tester, desktopWidth);
    await scrollTo(tester, find.byKey(const Key('revenue-chart')));
    final box = tester.getRect(find.byKey(const Key('revenue-chart')));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(Offset(box.right - 5, box.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('Revenue: 1,500 TJS'), findsOneWidget);
    expect(find.text('Sales: 2'), findsOneWidget);
  });

  testWidgets('USD toggle converts amounts', (tester) async {
    await pumpApp(tester, desktopWidth);
    await tester.tap(find.text(r'USD ($)'));
    await tester.pumpAndSettle();
    expect(find.text('137'), findsOneWidget); // 1,500 / 10.95
  });

  testWidgets('Record Sale dialog → POST /api/sales → dashboard reloads', (tester) async {
    final backend = await pumpApp(tester, desktopWidth);
    await tester.tap(find.byKey(const Key('record-sale')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sale-amount')), '250.50');
    await tester.tap(find.byKey(const Key('sale-save')));
    await tester.pumpAndSettle();
    expect(backend.requests, contains('POST /api/sales'));
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('1,751'), findsOneWidget);
  });

  testWidgets('"View All Stores" opens the Stores page', (tester) async {
    await pumpApp(tester, desktopWidth);
    await scrollTo(tester, find.byKey(const Key('view-all-stores')));
    await tester.tap(find.byKey(const Key('view-all-stores')));
    await tester.pumpAndSettle();
    expect(find.text('Store Management'), findsOneWidget);
    await openSection(tester, AppSection.dashboard);
  });

  testWidgets('dashboard AI card sends its question and opens the assistant', (tester) async {
    final backend = setUpBackend()..assistantReply = 'Today you sold 1500.00 TJS.';
    await pumpApp(tester, desktopWidth, backend: backend);
    await scrollTo(tester, find.byKey(const Key('ai-card-sales')));
    await tester.tap(find.byKey(const Key('ai-card-sales')));
    await tester.pumpAndSettle();
    expect(backend.lastChatRequest!['messages'], [
      {'role': 'user', 'text': 'How much did I sell today?'},
    ]);
    expect(find.text('Today you sold 1500.00 TJS.'), findsOneWidget);
  });

  testWidgets('a business registered today: the chart starts today, not 24 days back', (tester) async {
    final backend = setUpBackend();
    backend.user['createdAt'] = DateTime.now().toUtc().toIso8601String();
    backend.sales.removeWhere((x) => x['saleDate'] != FakeBackend.day(backend.today));
    await pumpApp(tester, desktopWidth, backend: backend);
    final vm = Provider.of<DashboardViewModel>(tester.element(find.byKey(const Key('dashboard-hero'))), listen: false);
    expect(vm.chartPoints, hasLength(1));
    final today = DateTime.now();
    expect(vm.chartPoints.single.date, DateTime(today.year, today.month, today.day));
  });

  testWidgets('a business registered 5 days ago gets 6 days on the chart', (tester) async {
    final backend = setUpBackend();
    backend.user['createdAt'] = DateTime.now().subtract(const Duration(days: 5)).toUtc().toIso8601String();
    final signUp = backend.today.subtract(const Duration(days: 5));
    backend.sales.removeWhere((x) => FakeBackend.parseDay(x['saleDate'] as String).isBefore(signUp));
    await pumpApp(tester, desktopWidth, backend: backend);
    final vm = Provider.of<DashboardViewModel>(tester.element(find.byKey(const Key('dashboard-hero'))), listen: false);
    expect(vm.chartPoints, hasLength(6));
  });

  testWidgets('sales entered for days before registration still show on the chart', (tester) async {
    final backend = setUpBackend();
    backend.user['createdAt'] = DateTime.now().toUtc().toIso8601String();
    final threeDaysAgo = backend.today.subtract(const Duration(days: 3));
    backend.sales.removeWhere((x) => FakeBackend.parseDay(x['saleDate'] as String).isBefore(threeDaysAgo));
    await pumpApp(tester, desktopWidth, backend: backend);
    final vm = Provider.of<DashboardViewModel>(tester.element(find.byKey(const Key('dashboard-hero'))), listen: false);
    // From the first sale (3 days ago) to today — the days the month's total is made of.
    expect(vm.chartPoints.first.date, threeDaysAgo);
    expect(vm.chartPoints, hasLength(4));
    expect(vm.chartPoints.first.revenue, greaterThan(0));
  });
}
