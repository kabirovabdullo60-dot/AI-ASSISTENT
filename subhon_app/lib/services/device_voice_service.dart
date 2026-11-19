import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'voice_service.dart';

/// [VoiceService] with the phone's own speech recognition
/// (`speech_to_text`) and voice (`flutter_tts`). Tajik falls back to
/// Russian where the phone has no Tajik.
class DeviceVoiceService implements VoiceService {
  // Created on first use: nothing touches the plugins until voice is used.
  late final SpeechToText _speech = SpeechToText();
  late final FlutterTts _tts = FlutterTts();
  bool _used = false;
  bool? _ready;
  void Function(bool failed)? _onStop;
  DateTime _started = DateTime.now();
  bool _heard = false;

  /// The phone's locale for a language, preferring the region it is
  /// usually spoken in.
  static const _locales = {'ru': 'ru_RU', 'en': 'en_US', 'tg': 'tg_TJ'};

  Future<bool> _init() async => _ready ??= await _speech.initialize(
    onStatus: (status) {
      if ((status == SpeechToText.doneStatus ||
              status == SpeechToText.notListeningStatus) &&
          !_heard) {
        // Stopping within a second without a word: the microphone did not
        // really start (e.g. no audio input in the simulator).
        final instant =
            DateTime.now().difference(_started) < const Duration(seconds: 1);
        _onStop?.call(instant);
      }
    },
    onError: (SpeechRecognitionError error) =>
        // "No match" is silence; anything else is a failure.
        _onStop?.call(
          error.errorMsg != 'error_no_match' &&
              error.errorMsg != 'error_speech_timeout',
        ),
  );

  @override
  Future<bool> listen({
    required String language,
    required void Function(String words, bool done) onWords,
    required void Function(bool failed) onStop,
  }) async {
    _used = true;
    if (!await _init()) return false;
    _onStop = onStop;
    _heard = false;
    _started = DateTime.now();
    final available = (await _speech.locales()).map((l) => l.localeId);
    String? pick(String lang) {
      final wanted = _locales[lang]!;
      return available.contains(wanted)
          ? wanted
          : available.where((id) => id.startsWith(lang)).firstOrNull;
    }

    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: pick(language) ?? pick('ru'),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
      onResult: (result) {
        final words = result.recognizedWords;
        if (result.finalResult) _heard = words.trim().isNotEmpty;
        onWords(words, result.finalResult);
      },
    );
    return true;
  }

  @override
  Future<void> stopListening() async {
    if (_used) await _speech.stop();
  }

  @override
  Future<void> speak(String text, String language) async {
    _used = true;
    await _tts.awaitSpeakCompletion(true);
    final wanted = switch (language) {
      'en' => 'en-US',
      'tg' => 'tg-TJ',
      _ => 'ru-RU',
    };
    final ok = await _tts.isLanguageAvailable(wanted);
    await _tts.setLanguage(ok == true ? wanted : 'ru-RU');
    await _tts.speak(text);
  }

  @override
  Future<void> stopSpeaking() async {
    if (_used) await _tts.stop();
  }
}
