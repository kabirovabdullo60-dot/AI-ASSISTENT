import 'package:abdullo_web/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpAt(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const WebApp());
}

void main() {
  testWidgets('mobile (400px): bottom NavigationBar, no rail', (tester) async {
    await pumpAt(tester, 400);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('tablet (800px): compact rail', (tester) async {
    await pumpAt(tester, 800);
    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('desktop (1400px): extended rail, tapping changes section', (tester) async {
    await pumpAt(tester, 1400);
    expect(tester.widget<NavigationRail>(find.byType(NavigationRail)).extended, isTrue);
    await tester.tap(find.text('Reports'));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('home-title'))).data,
      'Reports',
    );
  });
}
