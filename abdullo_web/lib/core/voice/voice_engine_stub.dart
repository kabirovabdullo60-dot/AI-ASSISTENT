import 'voice_exception.dart';

// Not a browser (tests, desktop VM): no microphone, no speech.

bool get canListen => false;
bool get canSpeak => false;

void warmUp() {}

Future<String> listen(String lang, void Function(String partial)? onPartial) =>
    Future.error(const VoiceException('unsupported'));

void stopListening() {}

Future<void> speak(String text, List<String> langs) async {}

void stopSpeaking() {}
