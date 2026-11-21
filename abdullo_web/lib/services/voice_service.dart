import '../core/voice/voice_engine_stub.dart'
    if (dart.library.js_interop) '../core/voice/voice_engine_web.dart'
    as engine;
import '../core/voice/voice_exception.dart';

export '../core/voice/voice_exception.dart';

/// Microphone → text and text → speech, in the browser (Web Speech API).
/// [language] is the app language: 'en' / 'ru' / 'tg'.
class VoiceService {
  VoiceService() {
    engine.warmUp();
  }

  bool get canListen => engine.canListen;
  bool get canSpeak => engine.canSpeak;

  /// Listens to one phrase and returns it ('' if nothing was said before [stopListening]).
  /// [onPartial] gets the text while the user is still speaking.
  /// Throws [VoiceException]. Tajik recognition falls back to Russian if the browser lacks it.
  Future<String> listen({required String language, void Function(String partial)? onPartial}) async {
    final langs = _recognitionLangs(language);
    for (var i = 0; i < langs.length; i++) {
      try {
        return await engine.listen(langs[i], onPartial);
      } on VoiceException catch (e) {
        if (e.code != 'language-not-supported' || i == langs.length - 1) rethrow;
      }
    }
    return '';
  }

  void stopListening() => engine.stopListening();

  /// Reads [text] aloud; completes when it has been spoken (or stopped).
  Future<void> speak(String text, {required String language}) =>
      engine.speak(spokenText(text, language), _speechLangs(language));

  void stopSpeaking() => engine.stopSpeaking();

  static List<String> _recognitionLangs(String language) => switch (language) {
    'ru' => const ['ru-RU'],
    'tg' => const ['tg-TJ', 'ru-RU'],
    _ => const ['en-US'],
  };

  static List<String> _speechLangs(String language) => switch (language) {
    'ru' => const ['ru-RU'],
    // Few browsers ship a Tajik voice; a Russian one reads Tajik Cyrillic well enough.
    'tg' => const ['tg-TJ', 'ru-RU'],
    _ => const ['en-US', 'en-GB'],
  };

  /// Answer text as it should sound: no markdown marks, "TJS" said as a word.
  static String spokenText(String text, String language) {
    final somoni = switch (language) {
      'ru' => 'сомони',
      'tg' => 'сомонӣ',
      _ => 'somoni',
    };
    return text
        .replaceAll(RegExp(r'[*_#`>|]+'), '')
        .replaceAll(RegExp(r'\bTJS\b'), somoni)
        .replaceAll(RegExp(r'\s*\n+\s*'), '. ')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }
}
