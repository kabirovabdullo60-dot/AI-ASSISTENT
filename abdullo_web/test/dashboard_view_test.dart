import 'package:abdullo_web/widgets/kpi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('dashboard at ${width.toInt()}px shows KPIs, chart and insights', (tester) async {
      await pumpAt(tester, width);
      expect(find.byKey(const Key('dashboard-view')), findsOneWidget);
      expect(find.byType(KpiCard), findsNWidgets(4));
      expect(find.text('Revenue'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('AI insights'), 200);
      expect(find.text('AI insights'), findsOneWidget);
    });
  }

  testWidgets('desktop puts 4 KPI cards in one row, mobile in two', (tester) async {
    await pumpAt(tester, desktopWidth);
    final cards = find.byType(KpiCard);
    expect(tester.getTopLeft(cards.at(0)).dy, tester.getTopLeft(cards.at(3)).dy);

    await pumpAt(tester, mobileWidth);
    expect(tester.getTopLeft(cards.at(0)).dy, lessThan(tester.getTopLeft(cards.at(3)).dy));
  });
}
