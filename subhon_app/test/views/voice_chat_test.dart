import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/fake_voice_service.dart';
import '../helpers/memory_token_storage.dart';

Future<FakeBackend> _openVoice(
  WidgetTester tester,
  FakeVoiceService voice,
) async {
  final backend = FakeBackend()
    ..json('GET', '/api/auth/me', ApiJson.profile())
    ..json('POST', '/api/assistant/chat', {
      'role': 'assistant',
      'text': 'У вас 7 сотрудников, работают 6.',
      'time': '2026-11-19T09:00:00Z',
      'conversationId': '33333333-3333-3333-3333-333333333333',
    });
  stubHome(backend);
  await pumpApp(
    tester,
    backend,
    voice: voice,
    tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
  );
  await tester.tap(find.byTooltip('ИИ-ассистент'));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Говорить голосом').first);
  await tester.pumpAndSettle();
  return backend;
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('voice: "сотрудники" is understood, answered and read aloud; '
      'then it listens again', (tester) async {
    final voice = FakeVoiceService();
    final backend = await _openVoice(tester, voice);
    expect(find.text('Слушаю…'), findsOneWidget);
    expect(voice.languages.single, 'ru');

    voice.say('сотрудники');
    await tester.pumpAndSettle();

    final body =
        jsonDecode(backend.calls('POST', '/api/assistant/chat').single.body)
            as Map<String, dynamic>;
    final sent = (body['messages'] as List).single as Map<String, dynamic>;
    expect(sent['text'], contains('«сотрудники»'));
    expect(sent['text'], contains('сколько всего сотрудников'));
    expect(voice.spoken, ['У вас 7 сотрудников, работают 6.']);
    // A conversation: listening again after the answer.
    expect(voice.listens, 2);
    expect(find.text('Слушаю…'), findsOneWidget);

    // Back in the chat the person's own words are shown, not the prompt.
    await tester.tap(find.byTooltip('Завершить'));
    await tester.pumpAndSettle();
    expect(find.text('сотрудники'), findsOneWidget);
    expect(find.text('У вас 7 сотрудников, работают 6.'), findsOneWidget);
  });

  testWidgets('silence: it waits for a tap on the microphone', (tester) async {
    final voice = FakeVoiceService();
    await _openVoice(tester, voice);
    voice.silence();
    await tester.pumpAndSettle();
    expect(find.text('Нажмите на микрофон и говорите'), findsOneWidget);
    await tester.tap(find.byTooltip('Говорить'));
    await tester.pumpAndSettle();
    expect(voice.listens, 2);
  });

  testWidgets('no microphone permission: a clear message', (tester) async {
    await _openVoice(tester, FakeVoiceService(available: false));
    expect(
      find.textContaining('Распознавание речи недоступно'),
      findsOneWidget,
    );
  });

  testWidgets('the microphone stops at once: it says so', (tester) async {
    final voice = FakeVoiceService();
    await _openVoice(tester, voice);
    voice.fail();
    await tester.pumpAndSettle();
    expect(find.textContaining('Микрофон не включился'), findsOneWidget);
    // A new try clears the message.
    await tester.tap(find.byTooltip('Говорить'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Микрофон не включился'), findsNothing);
  });
}
