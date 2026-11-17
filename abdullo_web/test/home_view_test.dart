import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('mobile (400px): bottom NavigationBar, no sidebar', (tester) async {
    await pumpAt(tester, mobileWidth);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(AppSidebar), findsNothing);
  });

  testWidgets('tablet (800px): compact sidebar', (tester) async {
    await pumpAt(tester, tabletWidth);
    expect(tester.widget<AppSidebar>(find.byType(AppSidebar)).extended, isFalse);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('desktop (1400px): extended sidebar', (tester) async {
    await pumpAt(tester, desktopWidth);
    expect(tester.widget<AppSidebar>(find.byType(AppSidebar)).extended, isTrue);
    expect(tester.getSize(find.byKey(const Key('app-sidebar'))).width, AppSidebar.extendedWidth);
  });

  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('every page opens without layout errors at ${width.toInt()}px', (tester) async {
      await pumpAt(tester, width);
      for (final s in AppSection.values) {
        await openSection(tester, s);
        expect(
          find.text(s == AppSection.assistant ? 'Ask your business assistant' : s.label),
          findsWidgets,
          reason: s.name,
        );
      }
    });
  }

  testWidgets('mobile "More" sheet opens Salaries', (tester) async {
    await pumpAt(tester, mobileWidth);
    await openSection(tester, AppSection.salaries);
    expect(find.byKey(const Key('payroll-table')), findsOneWidget);
  });
}
