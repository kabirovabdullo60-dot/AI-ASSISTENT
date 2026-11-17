import 'package:abdullo_web/core/l10n/app_language.dart';
import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/core/utils/format.dart';
import 'package:abdullo_web/services/assistant_service.dart';
import 'package:abdullo_web/services/mock/mock_database.dart';
import 'package:abdullo_web/services/preferences_service.dart';
import 'package:abdullo_web/viewmodels/settings_view_model.dart';
import 'package:abdullo_web/widgets/page_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  testWidgets('top-bar menu switches English → Русский → Тоҷикӣ', (tester) async {
    await pumpAt(tester, desktopWidth);
    expect(find.text('Business Overview'), findsOneWidget);

    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-ru')));
    await tester.pumpAndSettle();
    expect(find.text('Обзор бизнеса'), findsOneWidget);
    expect(find.text('Магазины'), findsWidgets);

    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-tg')));
    await tester.pumpAndSettle();
    expect(find.text('Шарҳи тиҷорат'), findsOneWidget);
    expect(find.text('Мағозаҳо'), findsWidgets);
    expect((await SharedPreferences.getInstance()).getString('language'), 'tg');
  });

  for (final lang in ['ru', 'tg']) {
    for (final width in [mobileWidth, desktopWidth]) {
      testWidgets('[$lang] every page fits at ${width.toInt()}px', (tester) async {
        await pumpAt(tester, width, language: lang);
        for (final s in AppSection.values) {
          await openSection(tester, s);
          if (s != AppSection.assistant) expect(find.byType(PageBody), findsOneWidget, reason: '$lang ${s.name}');
        }
      });
    }
  }

  testWidgets('[tg] date picker works (Material texts fall back to Russian)', (tester) async {
    await pumpAt(tester, desktopWidth, language: 'tg');
    await openSection(tester, AppSection.sales);
    await tester.tap(find.byKey(const Key('sale-date')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

  testWidgets('[ru] assistant answers in Russian', (tester) async {
    await pumpAt(tester, desktopWidth, language: 'ru');
    await openSection(tester, AppSection.assistant);
    await tester.tap(find.text('Продажи сегодня'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Продажи сегодня: 36,750 TJS'), findsOneWidget);
  });

  test('saved language is restored', () async {
    resetDemoData({'language': 'ru'});
    final vm = SettingsViewModel(PreferencesService(), systemLanguage: 'en');
    expect(vm.language, AppLanguage.en);
    await vm.load();
    expect(vm.language, AppLanguage.ru);
    vm.setLanguage(AppLanguage.tg);
    expect((await SharedPreferences.getInstance()).getString('language'), 'tg');
    setFormatLanguage('en');
  });

  test('dates and "time ago" follow the language', () {
    final d = DateTime(2026, 11, 6, 9);
    setFormatLanguage('en');
    expect(formatDay(d), 'Nov 06');
    expect(formatMonthYear(d), 'November 2026');
    setFormatLanguage('ru');
    expect(formatDay(d), '6 ноя');
    expect(formatMonthYear(d), 'Ноябрь 2026');
    expect(formatTimeAgo(d, now: d.add(const Duration(minutes: 5))), '5 мин назад');
    setFormatLanguage('tg');
    expect(formatWeekday(d), 'Ҷм');
    expect(formatMonthYear(d), 'Ноябр 2026');
    expect(formatTimeAgo(d, now: d.add(const Duration(hours: 3))), '3 соат пеш');
    setFormatLanguage('en');
  });

  test('demo assistant replies in all three languages', () {
    resetDemoData();
    final db = MockDatabase.instance;
    expect(AssistantService.mockReply('sales?', db), startsWith("Today's sales"));
    expect(AssistantService.mockReply('sales?', db, language: 'ru'), startsWith('Продажи сегодня'));
    expect(AssistantService.mockReply('фурӯш?', db, language: 'tg'), startsWith('Фурӯши имрӯза'));
  });
}
