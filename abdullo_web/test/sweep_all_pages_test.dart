// Opens every page at five screen widths in all three languages and fails on any
// exception or layout overflow.
import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/core/theme/app_colors.dart';
import 'package:abdullo_web/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final lang in ['en', 'ru', 'tg']) {
    for (final width in [360.0, 400.0, 800.0, 1024.0, 1440.0]) {
      testWidgets('all pages at ${width.toInt()}px in $lang', (tester) async {
        final backend = setUpBackend(language: lang)
          ..targets.addAll({'WEEK': '3000.00', 'MONTH': '12000.00'})
          ..notifications.add({
            'id': 'n1', 'kind': 'UNPAID_SALARIES', 'severity': 'INFO', 'count': 2, 'amount': '4200.00',
            'storeId': null, 'storeName': null, 'link': 'PAYROLL', 'read': false, 'createdAt': '2026-11-01T00:00:00Z',
          });
        await pumpApp(tester, width, height: 900, backend: backend);
        for (final s in AppSection.values) {
          await openSection(tester, s);
          final e = tester.takeException();
          if (e != null) debugPrint('OVERFLOW-PAGE ${s.name} ${width.toInt()} $lang: $e');
          expect(e, isNull);
        }
        // A dialog and the bell menu too.
        await openSection(tester, AppSection.expenses);
        await tester.tap(find.byKey(const Key('add-expense')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'expense dialog');
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('notifications')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'notifications menu');
      });
    }
  }

  // The two light looks at phone and desktop width.
  for (final palette in [AppPalette.zinc, AppPalette.emerald]) {
    for (final width in [400.0, 1440.0]) {
      testWidgets('all pages in ${palette.name} at ${width.toInt()}px', (tester) async {
        AppColors.use(palette);
        addTearDown(() => AppColors.use(AppPalette.aurora));
        await pumpApp(tester, width, height: 900);
        for (final s in AppSection.values) {
          await openSection(tester, s);
          expect(tester.takeException(), isNull, reason: '${s.name} in ${palette.name}');
        }
      });
    }
  }
}
