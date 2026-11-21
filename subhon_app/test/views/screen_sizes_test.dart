import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/l10n/generated/app_localizations.dart';
import 'package:subhon_app/widgets/bottom_nav_item.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

/// Scrolls the screen's list to the end so every lazy item is built (and
/// laid out at this width).
Future<void> _scrollAll(WidgetTester tester) async {
  final lists = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  if (lists.evaluate().isEmpty) return;
  for (var i = 0; i < 6; i++) {
    await tester.drag(lists.last, const Offset(0, -900), warnIfMissed: false);
    await tester.pumpAndSettle();
  }
}

Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton).last);
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final lists = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  if (find.text(text).evaluate().isEmpty && lists.evaluate().isNotEmpty) {
    // Back to the top first (the list may have been scrolled down before).
    for (var i = 0; i < 6; i++) {
      await tester.drag(lists.last, const Offset(0, 900), warnIfMissed: false);
      await tester.pumpAndSettle();
    }
    if (find.text(text).evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        find.text(text),
        200,
        scrollable: lists.last,
      );
    }
  }
  await tester.ensureVisible(find.text(text).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in const [Size(360, 640), Size(430, 932)]) {
    for (final lang in const ['en', 'ru', 'tg']) {
      testWidgets('no overflow on a ${size.width.toInt()} px phone in $lang', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final l10n = lookupAppLocalizations(Locale(lang));
        final backend = FakeBackend()
          ..json('GET', '/api/auth/me', ApiJson.profile());
        stubHome(backend);
        await pumpApp(
          tester,
          backend,
          locale: Locale(lang),
          tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
        );

        // Home ("Мои финансы") to the end.
        await _scrollAll(tester);

        // The other tabs.
        for (final i in [1, 2, 3]) {
          await tester.tap(find.byType(BottomNavItem).at(i));
          await tester.pumpAndSettle();
          await _scrollAll(tester);
        }

        // "+" and two of its forms.
        await tester.tap(find.byTooltip(l10n.navAdd));
        await tester.pumpAndSettle();
        await _tapText(tester, l10n.pfExpense);
        await _scrollAll(tester);
        await _back(tester);
        await tester.tap(find.byTooltip(l10n.navAdd));
        await tester.pumpAndSettle();
        await _tapText(tester, l10n.qeTitle);
        await tester.enterText(find.byType(TextField).first, 'такси 50');
        await tester.pumpAndSettle();
        await _back(tester);

        // The AI chat with its suggestions.
        await tester.tap(find.byTooltip(l10n.assistantTitle));
        await tester.pumpAndSettle();
        await _back(tester);

        // The shop's dashboard from "Мой бизнес".
        await tester.tap(find.byType(BottomNavItem).at(0));
        await tester.pumpAndSettle();
        await _tapText(tester, l10n.phOpen);
        await _scrollAll(tester);
        await _back(tester);

        // "Ещё" → accounts, goals, regular payments.
        for (final row in [l10n.pfAccounts, l10n.goalTitle, l10n.pfRecurring]) {
          await tester.tap(find.byType(BottomNavItem).at(3));
          await tester.pumpAndSettle();
          await _tapText(tester, row);
          await _scrollAll(tester);
          await _back(tester);
        }
        // The business part and currencies.
        for (final row in [
          l10n.navStores,
          l10n.navEmployees,
          l10n.navExpenses,
          l10n.navCurrencies,
          l10n.bkTitle,
        ]) {
          await tester.tap(find.byType(BottomNavItem).at(3));
          await tester.pumpAndSettle();
          await _tapText(tester, row);
          await _scrollAll(tester);
          await _back(tester);
        }
        await tester.tap(find.byType(BottomNavItem).at(3));
        await tester.pumpAndSettle();
        await _tapText(tester, l10n.navReports);
        await _tapText(tester, l10n.reportProfit);
        await _scrollAll(tester);
        await _back(tester);
        await _back(tester);
        for (final action in [l10n.actionSalesList, l10n.navPayroll]) {
          await tester.tap(find.byTooltip(l10n.navAdd));
          await tester.pumpAndSettle();
          await _tapText(tester, action);
          await _scrollAll(tester);
          await _back(tester);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
