import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/storage/secure_chat_history_storage.dart';
import 'package:subhon_app/models/chat_conversation_model.dart';
import 'package:subhon_app/models/chat_message_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_chat_history_storage.dart';
import '../helpers/memory_token_storage.dart';

const _user = '11111111-1111-1111-1111-111111111111';

Future<FakeBackend> _openChat(
  WidgetTester tester,
  MemoryChatHistoryStorage history,
) async {
  var n = 0;
  final backend = FakeBackend()
    ..json('GET', '/api/auth/me', ApiJson.profile())
    ..on('POST', '/api/assistant/chat', (_) {
      n++;
      return FakeBackend.respond({
        'role': 'assistant',
        'text': 'Ответ $n',
        'time': '2026-11-19T09:00:00Z',
      });
    });
  stubHome(backend);
  await pumpApp(
    tester,
    backend,
    chatHistory: history,
    tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
  );
  await tester.tap(find.byTooltip('ИИ-ассистент'));
  await tester.pumpAndSettle();
  return backend;
}

Future<void> _ask(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.byTooltip('Отправить'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('chats are saved; "Новый чат" starts over; a chat from the '
      'history opens and continues', (tester) async {
    final history = MemoryChatHistoryStorage();
    final backend = await _openChat(tester, history);
    expect(find.byTooltip('Говорить голосом'), findsOneWidget); // the mic

    await _ask(tester, 'Как продажи сегодня?');
    expect(history.byUser[_user], hasLength(1));
    expect(history.byUser[_user]!.single.title, 'Как продажи сегодня?');

    await tester.tap(find.byTooltip('Новый чат'));
    await tester.pumpAndSettle();
    expect(find.text('Ответ 1'), findsNothing);
    await _ask(tester, 'Сколько зарплаты осталось?');
    expect(history.byUser[_user], hasLength(2));
    // Newest first.
    expect(history.byUser[_user]!.first.title, 'Сколько зарплаты осталось?');

    await tester.tap(find.byTooltip('История чатов'));
    await tester.pumpAndSettle();
    expect(find.text('Открыт сейчас'), findsOneWidget);
    await tester.tap(find.text('Как продажи сегодня?'));
    await tester.pumpAndSettle();
    expect(find.text('Ответ 1'), findsOneWidget);

    // Continuing sends the whole saved conversation and keeps one entry.
    await _ask(tester, 'А вчера?');
    final body =
        jsonDecode(backend.calls('POST', '/api/assistant/chat').last.body)
            as Map<String, dynamic>;
    expect(body['messages'], hasLength(3));
    expect(history.byUser[_user], hasLength(2));
    expect(history.byUser[_user]!.first.title, 'Как продажи сегодня?');
  });

  testWidgets('a chat is deleted by swiping; "Удалить все" empties it', (
    tester,
  ) async {
    final history = MemoryChatHistoryStorage();
    await _openChat(tester, history);
    await _ask(tester, 'Первый вопрос?');
    await tester.tap(find.byTooltip('Новый чат'));
    await tester.pumpAndSettle();
    await _ask(tester, 'Второй вопрос?');

    await tester.tap(find.byTooltip('История чатов'));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Первый вопрос?'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Первый вопрос?'), findsNothing);
    expect(history.byUser[_user], hasLength(1));

    await tester.tap(find.byTooltip('Удалить все'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Удалить все').last);
    await tester.pumpAndSettle();
    expect(history.byUser[_user], isEmpty);
    expect(
      find.text('Здесь будут сохраняться ваши разговоры с ассистентом.'),
      findsOneWidget,
    );
  });

  test(
    'secure storage keeps chats per account and survives bad data',
    () async {
      FlutterSecureStorage.setMockInitialValues({'ofar.chats.u2': 'not json'});
      const storage = SecureChatHistoryStorage();
      final chat = ChatConversationModel(
        id: '1',
        updatedAt: DateTime(2026, 11, 19, 10),
        messages: [
          ChatMessageModel(
            fromUser: true,
            text: 'сотрудники',
            prompt: 'Коротко ответь про «сотрудники»…',
            time: DateTime(2026, 11, 19, 10),
          ),
          const ChatMessageModel(fromUser: false, text: 'У вас 7 сотрудников.'),
        ],
      );
      await storage.write('u1', [chat]);
      final read = await storage.read('u1');
      expect(
        read.single.messages.first.prompt,
        'Коротко ответь про «сотрудники»…',
      );
      expect(read.single.preview, 'У вас 7 сотрудников.');
      expect(await storage.read('u2'), isEmpty);
      expect(await storage.read('u3'), isEmpty);
    },
  );
}
