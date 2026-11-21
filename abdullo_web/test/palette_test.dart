import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/core/theme/app_colors.dart';
import 'package:abdullo_web/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  tearDown(() => AppColors.use(AppPalette.ledger));

  testWidgets('Settings switches the look and remembers it', (tester) async {
    await pumpApp(tester, desktopWidth);
    expect(AppColors.palette, AppPalette.ledger);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.light);
    expect(find.byKey(const Key('palette-menu')), findsNothing); // one place for it: Settings

    await openSection(tester, AppSection.settings);
    await scrollTo(tester, find.byKey(const Key('settings-palette-graphite')));
    await tester.tap(find.byKey(const Key('settings-palette-graphite')));
    await tester.pumpAndSettle();
    expect(AppColors.palette, AppPalette.graphite);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness, Brightness.dark);
    expect((await SharedPreferences.getInstance()).getString('palette'), 'graphite');
  });

  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('settings at ${width.toInt()}px: pick Graphite, page stays open', (tester) async {
      await pumpApp(tester, width);
      await openSection(tester, AppSection.settings);
      await scrollTo(tester, find.byKey(const Key('settings-palette-graphite')));
      await tester.tap(find.byKey(const Key('settings-palette-graphite')));
      await tester.pumpAndSettle();
      expect(AppColors.palette, AppPalette.graphite);
      expect(find.byKey(const Key('settings-palette-graphite')), findsOneWidget); // still on Settings
    });
  }
}
