import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('reports at $w: comparison + payroll year + AI analysis', (tester) async {
      await pumpApp(tester, width);
      await openSection(tester, AppSection.reports);
      await scrollTo(tester, find.byKey(const Key('reports-table')));
      await scrollTo(tester, find.byKey(const Key('payroll-year-table')));
      await scrollToTop(tester);
      await tester.tap(find.byKey(const Key('analyze-report')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatBubble), findsNWidgets(2));
      expect(find.textContaining('Report: this month'), findsOneWidget);
    });

    testWidgets('assistant at $w answers from real numbers', (tester) async {
      await pumpApp(tester, width);
      await openSection(tester, AppSection.assistant);
      await tester.enterText(find.byKey(const Key('chat-input')), 'How are my sales?');
      await tester.tap(find.byKey(const Key('chat-send')));
      await tester.pumpAndSettle();
      expect(find.textContaining("Today's sales are 1,500 TJS"), findsOneWidget);
    });

    testWidgets('profile at $w: edit + wrong current password', (tester) async {
      final backend = await pumpApp(tester, width);
      await openSection(tester, AppSection.profile);
      await tester.enterText(find.byKey(const Key('business-name')), 'Dushanbe Trade');
      await scrollTo(tester, find.byKey(const Key('profile-save')));
      await tester.tap(find.byKey(const Key('profile-save')));
      await tester.pumpAndSettle();
      expect(backend.user['business']['name'], 'Dushanbe Trade');
      expect(find.text('Dushanbe Trade'), findsWidgets);

      await scrollTo(tester, find.byKey(const Key('password-save')));
      await tester.enterText(find.byKey(const Key('current-password')), 'nope');
      await tester.enterText(find.byKey(const Key('new-password')), 'newpass1');
      await tester.tap(find.byKey(const Key('password-save')));
      await tester.pumpAndSettle();
      expect(find.text('The current password is incorrect.'), findsOneWidget);
    });

    testWidgets('settings at $w lists the endpoints', (tester) async {
      await pumpApp(tester, width);
      await openSection(tester, AppSection.settings);
      await scrollTo(tester, find.text('/api/payroll/employee/{employeeId}'));
    });
  }
}
