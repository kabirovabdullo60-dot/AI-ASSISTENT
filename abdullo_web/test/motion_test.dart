import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/main.dart';
import 'package:abdullo_web/widgets/motion/ai_orb.dart';
import 'package:abdullo_web/widgets/motion/typing_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  testWidgets('a page shows the shimmer skeleton while its data loads', (tester) async {
    final backend = setUpBackend()..latency = const Duration(milliseconds: 300);
    tester.view.physicalSize = const Size(desktopWidth, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(WebApp(httpClient: backend.client));
    for (var i = 0; i < 4 && find.byKey(const Key('page-skeleton')).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 320));
    }
    expect(find.byKey(const Key('page-skeleton')), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('page-skeleton')), findsNothing);
  });

  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('AI chat at ${width.toInt()}px: thinking indicator, then the answer types out', (tester) async {
      final backend = setUpBackend()..assistantReply = 'Store No. 1 sold the most this month.';
      await pumpApp(tester, width, backend: backend);
      await openSection(tester, AppSection.assistant);
      expect(find.byType(AiOrb), findsOneWidget); // big orb on the empty screen

      backend.latency = const Duration(milliseconds: 150);
      await tester.enterText(find.byKey(const Key('chat-input')), 'Which store sells best?');
      await tester.tap(find.byKey(const Key('chat-send')));
      await tester.pump();
      expect(find.byType(TypingIndicator), findsOneWidget);
      expect(find.text('Thinking…'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 160));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(TypingIndicator), findsNothing);
      expect(find.text('Store No. 1 sold the most this month.'), findsNothing); // still typing

      await tester.pumpAndSettle();
      expect(find.text('Store No. 1 sold the most this month.'), findsOneWidget);
    });
  }

  testWidgets('reduced motion: everything still works, answers appear at once', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final backend = setUpBackend()..assistantReply = 'Done.';
    await pumpApp(tester, mobileWidth, backend: backend);
    await openSection(tester, AppSection.assistant);
    await tester.enterText(find.byKey(const Key('chat-input')), 'Hi');
    await tester.tap(find.byKey(const Key('chat-send')));
    await tester.pumpAndSettle();
    expect(find.text('Done.'), findsOneWidget);
  });
}
