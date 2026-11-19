/// Talking with the AI assistant by voice: speech → text and text →
/// speech on the phone. Abstract so tests can use a fake.
abstract class VoiceService {
  /// Starts listening in [language] (`en` / `ru` / `tg`). [onWords] gets
  /// the words heard so far; `done` once the person has finished. [onStop]
  /// is called when listening ends without words: `failed` when the
  /// microphone or the recognizer did not work, `false` for silence.
  /// `false` when speech recognition can't be used (no permission, not
  /// supported).
  Future<bool> listen({
    required String language,
    required void Function(String words, bool done) onWords,
    required void Function(bool failed) onStop,
  });

  Future<void> stopListening();

  /// Reads [text] aloud in [language]; completes when it has been said.
  Future<void> speak(String text, String language);

  Future<void> stopSpeaking();
}
