import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/core/voice/voice_command.dart';
import 'package:abdullo_web/services/voice_service.dart';
import 'package:abdullo_web/views/sales_view.dart';
import 'package:abdullo_web/views/reports_view.dart';
import 'package:abdullo_web/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Microphone that "hears" the next phrase from [phrases] and remembers what it read aloud.
class FakeVoiceService extends VoiceService {
  FakeVoiceService(this.phrases);

  final List<Object> phrases;
  final spoken = <String>[];
  final languages = <String>[];

  @override
  bool get canListen => true;
  @override
  bool get canSpeak => true;

  @override
  Future<String> listen({required String language, void Function(String partial)? onPartial}) async {
    languages.add(language);
    final next = phrases.removeAt(0);
    if (next is VoiceException) throw next;
    onPartial?.call(next as String);
    return next as String;
  }

  @override
  void stopListening() {}

  @override
  Future<void> speak(String text, {required String language}) async => spoken.add(text);

  @override
  void stopSpeaking() {}
}

AppSection? _opens(String text) => switch (VoiceCommand.parse(text)) {
  OpenSection(:final section) => section,
  _ => null,
};

void main() {
  group('VoiceCommand.parse', () {
    test('opens pages in en / ru / tg', () {
      expect(_opens('Open sales'), AppSection.sales);
      expect(_opens('go to the reports page'), AppSection.reports);
      expect(_opens('Открой продажи'), AppSection.sales);
      expect(_opens('Перейди в зарплаты'), AppSection.salaries);
      expect(_opens('Фурӯшро кушо'), AppSection.sales);
      expect(_opens('Мағозаҳоро кушоед'), AppSection.stores);
      expect(_opens('hisobotro kusho'), AppSection.reports);
      expect(_opens('Отчёты'), AppSection.reports);
      expect(_opens('Open salaries'), AppSection.salaries);
    });

    test('questions go to the assistant', () {
      for (final q in ['How much did I sell today?', 'Сколько продаж за неделю?', 'Фурӯши имрӯза чанд аст?']) {
        expect(VoiceCommand.parse(q), isA<AskAssistant>(), reason: q);
      }
      expect((VoiceCommand.parse(' Top stores? ') as AskAssistant).question, 'Top stores?');
    });

    test('new chat and stop', () {
      expect(VoiceCommand.parse('Новый чат'), isA<NewChat>());
      expect(VoiceCommand.parse('чати нав'), isA<NewChat>());
      expect(VoiceCommand.parse('Стоп'), isA<StopSpeaking>());
      expect(VoiceCommand.parse('бас'), isA<StopSpeaking>());
    });
  });

  test('spokenText drops markdown and says TJS as a word', () {
    expect(VoiceService.spokenText('**Top:**\n1. A — 10 TJS', 'tg'), 'Top:. 1. A — 10 сомонӣ');
    expect(VoiceService.spokenText('5 TJS', 'en'), '5 somoni');
  });

  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('voice command at $w opens a page', (tester) async {
      final voice = FakeVoiceService(['Open sales', 'Открой отчёты']);
      await pumpApp(tester, width, voice: voice);

      await tester.tap(find.byKey(const Key('voice-mic')));
      await tester.pumpAndSettle();
      expect(find.byType(SalesView), findsOneWidget);
      expect(find.text('Opened: Sales'), findsOneWidget);
      expect(voice.languages, ['en']);

      await tester.tap(find.byKey(const Key('voice-mic')));
      await tester.pumpAndSettle();
      expect(find.byType(ReportsView), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.textContaining('Opened:'), findsNothing);
    });

    testWidgets('spoken question at $w is answered and read aloud', (tester) async {
      final backend = setUpBackend()..assistantReply = 'Today you sold 1500.00 TJS.';
      final voice = FakeVoiceService(['How much did I sell today?']);
      await pumpApp(tester, width, backend: backend, voice: voice);
      await openSection(tester, AppSection.assistant);
      expect(find.byKey(const Key('voice-hint')), findsOneWidget);

      await tester.tap(find.byKey(const Key('voice-mic-chat')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatBubble), findsNWidgets(2));
      expect(find.textContaining('How much did I sell today?'), findsWidgets);
      expect(voice.spoken, ['Today you sold 1500.00 TJS.']);
    });

    testWidgets('voice replies can be turned off at $w', (tester) async {
      final backend = setUpBackend()..assistantReply = 'Hello!';
      final voice = FakeVoiceService(['Hi there, who are you?']);
      await pumpApp(tester, width, backend: backend, voice: voice);
      await openSection(tester, AppSection.assistant);
      await tester.tap(find.byKey(const Key('voice-replies')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('voice-mic-chat')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatBubble), findsNWidgets(2));
      expect(voice.spoken, isEmpty);
    });

    testWidgets('blocked microphone at $w shows a message', (tester) async {
      final voice = FakeVoiceService([const VoiceException('not-allowed')]);
      await pumpApp(tester, width, voice: voice);
      await tester.tap(find.byKey(const Key('voice-mic')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Microphone access is blocked'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('no mic button when the browser cannot listen', (tester) async {
    await pumpApp(tester, desktopWidth);
    expect(find.byKey(const Key('voice-mic')), findsNothing);
  });
}
