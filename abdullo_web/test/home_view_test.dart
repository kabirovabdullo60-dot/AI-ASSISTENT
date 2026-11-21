import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/widgets/app_sidebar.dart';
import 'package:abdullo_web/widgets/page_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('mobile (400px): bottom NavigationBar, no sidebar', (tester) async {
    await pumpApp(tester, mobileWidth);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(AppSidebar), findsNothing);
  });

  testWidgets('tablet (800px): compact sidebar', (tester) async {
    await pumpApp(tester, tabletWidth);
    expect(tester.widget<AppSidebar>(find.byType(AppSidebar)).extended, isFalse);
  });

  testWidgets('desktop (1400px): extended sidebar, search in the top bar, no greeting', (tester) async {
    await pumpApp(tester, desktopWidth);
    expect(tester.widget<AppSidebar>(find.byType(AppSidebar)).extended, isTrue);
    expect(find.byKey(const Key('global-search')), findsOneWidget);
    expect(find.textContaining('Hello'), findsNothing);
  });

  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('every page opens without layout errors at ${width.toInt()}px', (tester) async {
      await pumpApp(tester, width);
      for (final s in AppSection.values) {
        await openSection(tester, s);
        expect(
          s == AppSection.assistant ? find.text('Ask your business assistant') : find.byType(PageBody),
          findsOneWidget,
          reason: s.name,
        );
      }
    });
  }
}
