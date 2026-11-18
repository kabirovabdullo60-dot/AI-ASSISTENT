import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('dashboard at ${width.toInt()}px: set targets → PUT /api/targets → progress', (tester) async {
      final backend = await pumpApp(tester, width);
      await scrollTo(tester, find.byKey(const Key('set-targets')));
      expect(find.text('No target set'), findsNWidgets(2));
      expect(find.byKey(const Key('month-profit')), findsOneWidget);

      await tester.tap(find.byKey(const Key('set-targets')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('target-week')), '3000');
      await tester.enterText(find.byKey(const Key('target-month')), '10000');
      await tester.tap(find.byKey(const Key('targets-save')));
      await tester.pumpAndSettle();

      expect(backend.requests.where((r) => r == 'PUT /api/targets').length, 2);
      expect(backend.targets, {'WEEK': '3000.00', 'MONTH': '10000.00'});
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('No target set'), findsNothing);
      expect(find.textContaining('/ 3,000 TJS'), findsOneWidget);
    });
  }
}
