import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('reports at ${width.toInt()}px shows totals and table', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, 'Reports');
      expect(find.text('232,450 TJS'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(DataTable),
        200,
        scrollable: find
            .descendant(of: find.byKey(const Key('reports-view')), matching: find.byType(Scrollable))
            .first,
      );
      expect(find.byType(DataTable), findsOneWidget);
    });
  }

  testWidgets('"Analyze with AI" opens the assistant with an answer', (tester) async {
    await pumpAt(tester, desktopWidth);
    await openSection(tester, 'Reports');
    await tester.tap(find.byKey(const Key('analyze-report')));
    await tester.pumpAndSettle();
    expect(find.text('Analyze my sales report'), findsOneWidget);
    expect(find.textContaining('total revenue 232,450 TJS'), findsOneWidget);
  });
}
