import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/models/activity_model.dart';
import 'package:abdullo_web/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Map<String, dynamic> _row(String type, String action, String name, {String? amount, String? status}) => {
  'id': 'a-$name-$action',
  'type': type,
  'action': action,
  'entityId': 'e-1',
  'entityName': name,
  'storeId': null,
  'storeName': null,
  'employeeId': null,
  'amount': amount,
  'note': null,
  'changedFields': null,
  'status': status,
  'period': null,
  'actorId': 'u-1',
  'actorName': 'Abdullo Kabirov',
  'createdAt': DateTime.now().toUtc().toIso8601String(),
};

Future<void> _ask(WidgetTester tester, String text) async {
  await openSection(tester, AppSection.assistant);
  await tester.enterText(find.byKey(const Key('chat-input')), text);
  await tester.tap(find.byKey(const Key('chat-send')));
  await tester.pumpAndSettle();
}

void main() {
  test('ActivityModel.fromJson reads ActivityOut', () {
    final a = ActivityModel.fromJson(_row('STORE', 'STATUS_CHANGED', 'Central Plaza', status: 'INACTIVE'));
    expect(a.type, ActivityType.store);
    expect(a.action, ActivityAction.statusChanged);
    expect(a.title, 'Central Plaza');
    expect(a.amount, isNull);
    expect(a.detail, 'INACTIVE');
    expect(ActivityModel.fromJson(_row('PAYROLL', 'PAID', 'Ali', amount: '-3000.00')).amount, -3000);
  });

  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('dashboard at $w shows GET /api/activity rows', (tester) async {
      final backend = setUpBackend()
        ..activity.addAll([
          _row('STORE', 'CREATED', 'Khujand Branch'),
          _row('EMPLOYEE', 'UPDATED', 'Zarina Saidova'),
        ]);
      await pumpApp(tester, width, backend: backend);
      expect(backend.requests, contains('GET /api/activity'));
      await scrollTo(tester, find.text('Recent Business Activity'));
      await scrollTo(tester, find.textContaining('Khujand Branch'));
      expect(find.textContaining('created'), findsWidgets);
    });

    testWidgets('assistant at $w answers from POST /api/assistant/chat', (tester) async {
      final backend = setUpBackend()..assistantReply = 'Today you sold 1500.00 TJS in 2 sales.';
      await pumpApp(tester, width, backend: backend);
      await _ask(tester, 'How are my sales today?');
      expect(find.text('Today you sold 1500.00 TJS in 2 sales.'), findsOneWidget);
      expect(find.byType(ChatBubble), findsNWidgets(2));
      expect(backend.lastChatRequest!['language'], 'en');
      expect(backend.lastChatRequest!['messages'], [
        {'role': 'user', 'text': 'How are my sales today?'},
      ]);
    });
  }

  testWidgets('assistant shows "too many questions" on 429 RATE_LIMITED', (tester) async {
    final backend = setUpBackend()..assistantRateLimited = true;
    await pumpApp(tester, desktopWidth, backend: backend);
    await _ask(tester, 'How are my sales?');
    expect(find.text('Too many questions. Wait a minute and ask again.'), findsOneWidget);
  });
}
