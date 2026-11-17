import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('settings at ${width.toInt()}px: name goes to app bar, dark mode works', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, 'Settings');

      await tester.enterText(find.byKey(const Key('business-name')), 'Dushanbe Coffee');
      await tester.pumpAndSettle();
      expect(find.textContaining('Dushanbe Coffee'), findsWidgets);

      await tester.tap(find.byKey(const Key('dark-mode')));
      await tester.pumpAndSettle();
      expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode, ThemeMode.dark);
    });
  }
}
