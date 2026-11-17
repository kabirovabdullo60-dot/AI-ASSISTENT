import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('stores at $w: all 8 stores, search filters', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.stores);
      expect(find.text('Central Plaza Store'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('global-search')), 'rudaki');
      await tester.pumpAndSettle();
      expect(find.text('Rudaki Mall Kiosk'), findsOneWidget);
      expect(find.text('Central Plaza Store'), findsNothing);
    });

    testWidgets('sales at $w: receipts table', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.sales);
      await scrollTo(tester, find.text('POS-88219'));
    });

    testWidgets('employees at $w: staff table', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.employees);
      await scrollTo(tester, find.text('Zarina Karimova'));
    });

    testWidgets('salaries at $w: pay one salary', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.salaries);
      expect(find.text('14,200 TJS'), findsOneWidget);
      await scrollTo(tester, find.byKey(const Key('pay-p1')));
      await tester.tap(find.byKey(const Key('pay-p1')));
      await tester.pumpAndSettle();
      expect(find.text('10,400 TJS'), findsOneWidget);
    });

    testWidgets('reports at $w: table + AI analysis', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.reports);
      await scrollTo(tester, find.byKey(const Key('reports-table')));
      await tester.drag(find.byKey(const Key('reports-table')), const Offset(0, 2000));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('analyze-report')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatBubble), findsNWidgets(2));
      expect(find.textContaining('Report: this month'), findsOneWidget);
    });

    testWidgets('assistant at $w: answers a question', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.assistant);
      await tester.enterText(find.byKey(const Key('chat-input')), 'How are my sales?');
      await tester.tap(find.byKey(const Key('chat-send')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatBubble), findsNWidgets(2));
      expect(find.textContaining('38,450 TJS'), findsOneWidget);
    });

    testWidgets('profile at $w', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.profile);
      expect(find.byKey(const Key('profile-name')), findsOneWidget);
    });

    testWidgets('settings at $w: business name + endpoint list', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, AppSection.settings);
      await tester.enterText(find.byKey(const Key('business-name')), 'Dushanbe Trade');
      await tester.pumpAndSettle();
      expect(find.textContaining('Dushanbe Trade'), findsWidgets);
      await scrollTo(tester, find.text('/payroll/{id}/pay'));
    });
  }
}
