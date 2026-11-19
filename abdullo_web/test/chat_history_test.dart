import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/main.dart';
import 'package:abdullo_web/models/chat_message_model.dart';
import 'package:abdullo_web/models/conversation_model.dart';
import 'package:abdullo_web/widgets/chat_bubble.dart';
import 'package:abdullo_web/widgets/app_sidebar.dart';
import 'package:abdullo_web/widgets/chat_history_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<void> _ask(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('chat-input')), text);
  await tester.tap(find.byKey(const Key('chat-send')));
  await tester.pumpAndSettle();
}

/// Desktop: the panel is always there. Phone: open the sheet with the history button.
Future<void> _showHistory(WidgetTester tester) async {
  if (find.byKey(const Key('history-panel')).evaluate().isNotEmpty) return;
  await tester.tap(find.byKey(const Key('chat-history')));
  await tester.pumpAndSettle();
}

Finder _inHistory(String text) => find.descendant(of: find.byType(ChatHistoryList), matching: find.text(text));

void main() {
  test('ConversationModel JSON round trip and title', () {
    final c = ConversationModel(
      id: 'c-1',
      title: ConversationModel.titleFrom('  How   much did I sell today?  '),
      createdAt: DateTime(2026, 11, 19, 9),
      updatedAt: DateTime(2026, 11, 19, 10),
      messages: [ChatMessageModel(role: ChatRole.user, text: 'Hi', time: DateTime(2026, 11, 19, 9))],
    );
    final back = ConversationModel.fromJson(c.toJson());
    expect(back.title, 'How much did I sell today?');
    expect(back.updatedAt, DateTime(2026, 11, 19, 10));
    expect(back.messages.single.text, 'Hi');
    expect(ConversationModel.titleFrom('x' * 200).length, ConversationModel.maxTitle);
  });

  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('history at $w: chats are saved, reopened and deleted', (tester) async {
      final backend = setUpBackend()..assistantReply = 'Answer.';
      await pumpApp(tester, width, backend: backend);
      await openSection(tester, AppSection.assistant);
      if (width >= desktopWidth) {
        expect(find.byKey(const Key('history-panel')), findsOneWidget);
        expect(find.byKey(const Key('chat-history')), findsNothing);
      } else {
        expect(find.byKey(const Key('history-panel')), findsNothing);
      }

      await _ask(tester, 'Sales today?');
      await _ask(tester, 'And this week?');
      await tester.tap(find.byKey(const Key('chat-new')));
      await tester.pumpAndSettle();
      await _ask(tester, 'Top stores?');

      await _showHistory(tester);
      expect(_inHistory('Sales today?'), findsOneWidget);
      expect(_inHistory('Top stores?'), findsOneWidget);
      expect(find.textContaining('· 4 messages'), findsOneWidget);

      // Reopen the first chat: its 4 messages come back.
      await tester.tap(_inHistory('Sales today?'));
      await tester.pumpAndSettle();
      expect(find.byType(ChatBubble), findsNWidgets(4));
      expect(find.text('And this week?'), findsOneWidget);

      // A new question continues it — no new chat appears.
      await _ask(tester, 'Thanks');
      await _showHistory(tester);
      expect(find.textContaining('· 6 messages'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(ChatHistoryList), matching: find.byIcon(Icons.delete_outline)),
        findsNWidgets(2),
      );

      // Delete "Top stores?" after confirming.
      final tile = find.ancestor(of: _inHistory('Top stores?'), matching: find.byType(InkWell)).first;
      await tester.tap(find.descendant(of: tile, matching: find.byIcon(Icons.delete_outline)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('history-delete-confirm')));
      await tester.pumpAndSettle();
      expect(_inHistory('Top stores?'), findsNothing);
      expect(_inHistory('Sales today?'), findsOneWidget);
    });

    testWidgets('history at $w survives reloading the page', (tester) async {
      final backend = setUpBackend()..assistantReply = 'Answer.';
      await pumpApp(tester, width, backend: backend);
      await openSection(tester, AppSection.assistant);
      await _ask(tester, 'Unpaid salaries?');

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(WebApp(httpClient: backend.client, splashDuration: Duration.zero));
      await tester.pumpAndSettle();
      await openSection(tester, AppSection.assistant);
      expect(find.byType(ChatBubble), findsNothing);
      await _showHistory(tester);
      expect(_inHistory('Unpaid salaries?'), findsOneWidget);
    });
  }

  testWidgets('desktop: history sits on the right and can be hidden', (tester) async {
    await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.assistant);
    final panel = find.byKey(const Key('history-panel'));
    expect(tester.getTopLeft(panel).dx, greaterThan(tester.getTopRight(find.byKey(const Key('chat-input'))).dx));
    expect(tester.getTopRight(panel).dx, greaterThan(desktopWidth - 40));

    double slot() => tester.getSize(find.byKey(const Key('history-slot'))).width;
    expect(slot(), 292);

    await tester.tap(find.byKey(const Key('history-hide')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(slot(), allOf(greaterThan(0), lessThan(292)), reason: 'slides, not jumps');
    await tester.pumpAndSettle();
    expect(slot(), 0);

    await tester.tap(find.byKey(const Key('history-show')));
    await tester.pumpAndSettle();
    expect(slot(), 292);
  });

  testWidgets('desktop: the button next to the logo collapses the menu', (tester) async {
    await pumpApp(tester, desktopWidth);
    double sidebarWidth() => tester.getSize(find.byKey(const Key('app-sidebar'))).width - 12; // minus its left margin
    expect(sidebarWidth(), AppSidebar.extendedWidth);
    await tester.tap(find.byKey(const Key('sidebar-toggle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));
    expect(
      sidebarWidth(),
      allOf(greaterThan(AppSidebar.compactWidth), lessThan(AppSidebar.extendedWidth)),
      reason: 'slides, not jumps',
    );
    await tester.pumpAndSettle();
    expect(sidebarWidth(), AppSidebar.compactWidth);
    // Still navigates while folded.
    await tester.tap(find.byKey(const Key('nav-assistant')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-panel')), findsOneWidget);
    await tester.tap(find.byKey(const Key('sidebar-toggle')));
    await tester.pumpAndSettle();
    expect(sidebarWidth(), AppSidebar.extendedWidth);
  });

  testWidgets('tablet has no menu toggle (always compact)', (tester) async {
    await pumpApp(tester, tabletWidth);
    expect(find.byKey(const Key('sidebar-toggle')), findsNothing);
  });

  testWidgets('empty history shows a hint', (tester) async {
    await pumpApp(tester, desktopWidth);
    await openSection(tester, AppSection.assistant);
    expect(find.byKey(const Key('history-empty')), findsOneWidget);
  });
}
