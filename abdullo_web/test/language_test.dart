import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/core/utils/format.dart';
import 'package:abdullo_web/widgets/page_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  testWidgets('top-bar menu switches English → Русский → Тоҷикӣ', (tester) async {
    await pumpApp(tester, desktopWidth);
    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-ru')));
    await tester.pumpAndSettle();
    expect(find.text('Обзор бизнеса'), findsOneWidget);
    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-tg')));
    await tester.pumpAndSettle();
    expect(find.text('Шарҳи тиҷорат'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('language'), 'tg');
  });

  for (final lang in ['ru', 'tg']) {
    for (final width in [mobileWidth, desktopWidth]) {
      testWidgets('[$lang] every page fits at ${width.toInt()}px', (tester) async {
        await pumpApp(tester, width, language: lang);
        for (final s in AppSection.values) {
          await openSection(tester, s);
          if (s != AppSection.assistant) expect(find.byType(PageBody), findsOneWidget, reason: '$lang ${s.name}');
        }
      });
    }
  }

  testWidgets('[tg] login page + backend error in Tajik', (tester) async {
    await pumpApp(tester, mobileWidth, signedIn: false, language: 'tg');
    await tester.enterText(find.byKey(const Key('login-email')), 'owner@test.tj');
    await tester.enterText(find.byKey(const Key('login-password')), 'wrong');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Почта ё парол нодуруст аст.'), findsOneWidget);
  });

  testWidgets('[tg] date picker works (Material texts fall back to Russian)', (tester) async {
    await pumpApp(tester, desktopWidth, language: 'tg');
    await openSection(tester, AppSection.sales);
    await tester.tap(find.byKey(const Key('sale-date')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  test('dates follow the language', () {
    final d = DateTime(2026, 11, 6, 9);
    setFormatLanguage('ru');
    expect(formatDay(d), '6 ноя');
    setFormatLanguage('tg');
    expect(formatMonthYear(d), 'Ноябр 2026');
    setFormatLanguage('en');
    expect(formatDay(d), 'Nov 06');
  });
}
