import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/chat_conversation_model.dart';
import 'package:subhon_app/models/chat_message_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_chat_history_storage.dart';
import '../helpers/memory_token_storage.dart';

const _user = '11111111-1111-1111-1111-111111111111';
const _c1 = 'c1111111-1111-1111-1111-111111111111';
const _c2 = 'c2222222-2222-2222-2222-222222222222';

Map<String, Object?> _summary(String id, String title) => {
  'id': id,
  'title': title,
  'messageCount': 2,
  'lastMessage': 'Ответ про $title',
  'createdAt': '2026-11-20T08:00:00Z',
  'updatedAt': '2026-11-20T09:00:00Z',
};

Map<String, Object?> _reply(String text, String conversationId) => {
  'role': 'assistant',
  'text': text,
  'time': '2026-11-21T09:00:00Z',
  'conversationId': conversationId,
  'actions': <Object>[],
};

Future<FakeBackend> _openChat(
  WidgetTester tester, {
  MemoryChatHistoryStorage? phone,
}) async {
  final backend = FakeBackend()..json('GET', '/api/auth/me', ApiJson.profile());
  stubHome(backend);
  await pumpApp(
    tester,
    backend,
    chatHistory: phone,
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

Map<String, dynamic> _body(FakeBackend backend, int i) =>
    jsonDecode(backend.calls('POST', '/api/assistant/chat')[i].body)
        as Map<String, dynamic>;

void main() {
  testWidgets('the chat continues with the conversationId of the reply; the '
      'answer comes in the language the question is written in', (
    tester,
  ) async {
    final backend = await _openChat(tester);
    backend.on(
      'POST',
      '/api/assistant/chat',
      (_) => FakeBackend.respond(_reply('Ответ', _c1)),
    );
    await _ask(tester, 'Сколько я продал сегодня?');
    await _ask(tester, 'Фурӯши имрӯза чанд аст?');
    expect(_body(backend, 0).containsKey('conversationId'), isFalse);
    expect(_body(backend, 0)['language'], 'ru');
    expect(_body(backend, 1)['conversationId'], _c1);
    expect(_body(backend, 1)['language'], 'tg');
  });

  testWidgets('history from the server: chats kept on the phone move there '
      'once; a chat opens with its messages and continues', (tester) async {
    final phone = MemoryChatHistoryStorage()
      ..byUser[_user] = [
        ChatConversationModel(
          id: 'old',
          updatedAt: DateTime(2026, 11, 10),
          messages: const [
            ChatMessageModel(fromUser: true, text: 'Старый вопрос'),
            ChatMessageModel(fromUser: false, text: 'Старый ответ'),
          ],
        ),
      ];
    final backend = await _openChat(tester, phone: phone);
    backend
      ..json('POST', '/api/assistant/conversations', {
        ..._summary(_c2, 'Старый вопрос'),
        'messages': <Object>[],
      }, status: 201)
      ..json(
        'GET',
        '/api/assistant/conversations',
        ApiJson.page([_summary(_c1, 'Продажи'), _summary(_c2, 'Старый')]),
      )
      ..json('GET', '/api/assistant/conversations/$_c1', {
        ..._summary(_c1, 'Продажи'),
        'messages': [
          {
            'role': 'user',
            'text':
                '[My personal finances…]\nTotal balance: 1.00.\n[Question]\n'
                'Как продажи?',
            'time': '2026-11-20T08:59:00Z',
          },
          {
            'role': 'assistant',
            'text': 'Продажи хорошие.',
            'time': '2026-11-20T09:00:00Z',
            'actions': <Object>[],
          },
        ],
      })
      ..on(
        'POST',
        '/api/assistant/chat',
        (_) => FakeBackend.respond(_reply('Дальше', _c1)),
      );

    await tester.tap(find.byTooltip('История чатов'));
    await tester.pumpAndSettle();
    final moved =
        jsonDecode(
              backend.calls('POST', '/api/assistant/conversations').single.body,
            )
            as Map<String, dynamic>;
    expect((moved['messages'] as List).first['text'], 'Старый вопрос');
    expect(phone.byUser[_user], isEmpty);
    expect(find.text('Продажи'), findsOneWidget);

    await tapText(tester, 'Продажи');
    // The note of personal finances is not shown in the saved question.
    expect(find.text('Как продажи?'), findsOneWidget);
    expect(find.text('Продажи хорошие.'), findsOneWidget);
    await _ask(tester, 'А вчера?');
    expect(_body(backend, 0)['conversationId'], _c1);
  });

  testWidgets('rename and delete a chat; the open chat deleted on the '
      'server (404) continues as a new one', (tester) async {
    final backend = await _openChat(tester);
    var chatCalls = 0;
    backend
      ..on('POST', '/api/assistant/chat', (request) {
        chatCalls++;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (chatCalls == 2 && body['conversationId'] == _c1) {
          return FakeBackend.error(404, 'CONVERSATION_NOT_FOUND', 'gone');
        }
        return FakeBackend.respond(_reply('Ок', chatCalls == 1 ? _c1 : _c2));
      })
      ..json(
        'GET',
        '/api/assistant/conversations',
        ApiJson.page([_summary(_c1, 'Продажи')]),
      )
      ..json(
        'PATCH',
        '/api/assistant/conversations/$_c1',
        _summary(_c1, 'Мои продажи'),
      )
      ..on(
        'DELETE',
        '/api/assistant/conversations/$_c1',
        (_) => FakeBackend.respond(null, status: 204),
      );

    await _ask(tester, 'Как продажи сегодня?');
    await tester.tap(find.byTooltip('История чатов'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Действия с чатом'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Переименовать');
    await tester.enterText(find.byType(TextField).last, 'Мои продажи');
    await tapText(tester, 'Сохранить');
    expect(
      jsonDecode(
        backend.calls('PATCH', '/api/assistant/conversations/$_c1').single.body,
      ),
      {'title': 'Мои продажи'},
    );
    expect(find.text('Мои продажи'), findsOneWidget);

    await tester.tap(find.byTooltip('Действия с чатом'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Удалить');
    await tapText(tester, 'Удалить');
    expect(
      backend.calls('DELETE', '/api/assistant/conversations/$_c1'),
      hasLength(1),
    );
    expect(find.text('Мои продажи'), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    // The "Чат удалён" message goes away first.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    await _ask(tester, 'А вчера?');
    // The deleted chat is not sent again: a new one is made.
    expect(_body(backend, 1).containsKey('conversationId'), isFalse);
    expect(find.text('Ок'), findsNWidgets(2));
  });
}
