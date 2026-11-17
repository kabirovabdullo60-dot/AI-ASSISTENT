import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('mobile (400px): bottom NavigationBar, no rail', (tester) async {
    await pumpAt(tester, mobileWidth);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('tablet (800px): compact rail', (tester) async {
    await pumpAt(tester, tabletWidth);
    expect(tester.widget<NavigationRail>(find.byType(NavigationRail)).extended, isFalse);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('desktop (1400px): extended rail, tapping changes section', (tester) async {
    await pumpAt(tester, desktopWidth);
    expect(tester.widget<NavigationRail>(find.byType(NavigationRail)).extended, isTrue);
    await openSection(tester, 'Reports');
    expect(find.byKey(const Key('reports-view')), findsOneWidget);
  });
}
