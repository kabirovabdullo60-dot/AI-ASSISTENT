import 'package:abdullo_web/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('assistant at ${width.toInt()}px answers a question', (tester) async {
      await pumpAt(tester, width);
      await openSection(tester, 'Assistant');
      expect(find.text('Ask your business assistant'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('chat-input')), 'How are my sales?');
      await tester.tap(find.byKey(const Key('chat-send')));
      await tester.pumpAndSettle();

      expect(find.byType(ChatBubble), findsNWidgets(2));
      expect(find.textContaining('48,250 TJS'), findsOneWidget);
    });
  }

  testWidgets('suggestion chip sends a question; new chat clears it', (tester) async {
    await pumpAt(tester, mobileWidth);
    await openSection(tester, 'Assistant');
    await tester.tap(find.text('Marketing ideas'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatBubble), findsNWidgets(2));

    await tester.tap(find.byTooltip('New chat'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatBubble), findsNothing);
  });
}
