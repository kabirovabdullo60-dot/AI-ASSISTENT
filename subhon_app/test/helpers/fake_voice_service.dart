import 'package:subhon_app/services/voice_service.dart';

/// A microphone and a voice for tests: [say] plays what the person says,
/// [spoken] keeps what the app read aloud.
class FakeVoiceService implements VoiceService {
  FakeVoiceService({this.available = true});

  final bool available;
  final List<String> spoken = [];
  final List<String> languages = [];
  int listens = 0;
  void Function(String words, bool done)? _onWords;
  void Function()? _onStop;

  bool get isListening => _onWords != null;

  /// The person says [words] (and stops talking).
  void say(String words) {
    final onWords = _onWords;
    _onWords = null;
    onWords?.call(words, true);
  }

  /// The person stays silent.
  void silence() {
    final onStop = _onStop;
    _onWords = null;
    onStop?.call();
  }

  @override
  Future<bool> listen({
    required String language,
    required void Function(String words, bool done) onWords,
    required void Function() onStop,
  }) async {
    if (!available) return false;
    listens++;
    languages.add(language);
    _onWords = onWords;
    _onStop = onStop;
    return true;
  }

  @override
  Future<void> stopListening() async => _onWords = null;

  @override
  Future<void> speak(String text, String language) async => spoken.add(text);

  @override
  Future<void> stopSpeaking() async {}
}
