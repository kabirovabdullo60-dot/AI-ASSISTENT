import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/network/api_client.dart';
import 'package:subhon_app/models/chat_message_model.dart';
import 'package:subhon_app/services/assistant_service.dart';
import 'package:subhon_app/viewmodels/chat_view_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

Map<String, Object?> _reply(String text) => {
  'role': 'assistant',
  'text': text,
  'time': '2026-11-18T09:00:05Z',
};

Future<FakeBackend> _openChat(WidgetTester tester) async {
  final backend = FakeBackend()..json('GET', '/api/auth/me', ApiJson.profile());
  stubHome(backend);
  await pumpApp(
    tester,
    backend,
    tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
  );
  await tester.tap(find.byTooltip('ИИ-ассистент'));
  await tester.pumpAndSettle();
  return backend;
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('a suggested question is asked in the app language; the '
      'answer is shown', (tester) async {
    final backend = await _openChat(tester);
    backend.json(
      'POST',
      '/api/assistant/chat',
      _reply('Сегодня продажи 6 940,50 TJS.'),
    );
    expect(find.text('Как продажи сегодня?'), findsOneWidget);
    await tapText(tester, 'Как продажи сегодня?');

    final body =
        jsonDecode(backend.calls('POST', '/api/assistant/chat').single.body)
            as Map<String, dynamic>;
    expect(body['language'], 'ru');
    final messages = body['messages'] as List<dynamic>;
    expect(messages.single, containsPair('role', 'user'));
    // My personal finances (the cash wallet on the phone) go before it.
    final sent = (messages.single as Map<String, dynamic>)['text'] as String;
    expect(sent, startsWith('[My personal finances'));
    expect(sent, contains('Total balance: 0.00'));
    expect(sent, endsWith('[Question]\nКак продажи сегодня?'));
    expect(find.textContaining('[My personal'), findsNothing);
    expect(find.text('Сегодня продажи 6 940,50 TJS.'), findsOneWidget);
  });

  testWidgets('the assistant is down: a translated text and "Повторить"', (
    tester,
  ) async {
    final backend = await _openChat(tester);
    var calls = 0;
    backend.on('POST', '/api/assistant/chat', (_) {
      calls++;
      return calls == 1
          ? FakeBackend.error(503, 'ASSISTANT_UNAVAILABLE', 'x')
          : FakeBackend.respond(_reply('Готово.'));
    });
    await tester.enterText(find.byType(TextField), 'Привет');
    await tester.tap(find.byTooltip('Отправить'));
    await tester.pumpAndSettle();
    expect(
      find.text('Ассистент сейчас недоступен. Попробуйте позже.'),
      findsOneWidget,
    );
    await tapText(tester, 'Повторить');
    expect(find.text('Готово.'), findsOneWidget);
    expect(find.text('Привет'), findsOneWidget); // asked once, not twice
  });

  test(
    'only the last 20 messages are sent; rate limit shows the wait',
    () async {
      final backend = FakeBackend();
      var sent = 0;
      backend.on('POST', '/api/assistant/chat', (request) {
        sent = ((jsonDecode(request.body) as Map)['messages'] as List).length;
        return sent < 20
            ? FakeBackend.respond(_reply('ok'))
            : FakeBackend.respond({
                'error': {
                  'code': 'RATE_LIMITED',
                  'message': 'x',
                  'details': <Object>[],
                  'meta': {'retryAfter': 12},
                  'requestId': null,
                },
              }, status: 429);
      });
      final vm = ChatViewModel(
        AssistantService(
          ApiClient(
            tokens: MemoryTokenStorage(accessToken: 'a'),
            client: backend.client,
          ),
        ),
      );
      for (var i = 0; i < 12; i++) {
        await vm.send('Вопрос $i', 'ru');
      }
      expect(sent, 20);
      expect(vm.error?.code, 'RATE_LIMITED');
      expect(vm.error?.meta['retryAfter'], 12);
      expect(vm.messages.last, isA<ChatMessageModel>());
      expect(vm.canRetry, isTrue);
    },
  );
}
