/// Why listening failed. [code] is the browser's SpeechRecognition error
/// (`not-allowed`, `no-speech`, `audio-capture`, `network`, `language-not-supported` …)
/// or `unsupported` when the browser has no speech recognition at all.
class VoiceException implements Exception {
  const VoiceException(this.code);

  final String code;

  @override
  String toString() => 'VoiceException($code)';
}
