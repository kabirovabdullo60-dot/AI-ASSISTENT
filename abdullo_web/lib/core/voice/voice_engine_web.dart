import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'voice_exception.dart';

// Browser Web Speech API: SpeechRecognition (Chrome / Edge / Safari) and speechSynthesis.

extension type _Recognition._(JSObject _) implements JSObject {
  external set lang(String value);
  external set interimResults(bool value);
  external set continuous(bool value);
  external set maxAlternatives(int value);
  external set onresult(JSFunction? value);
  external set onerror(JSFunction? value);
  external set onend(JSFunction? value);
  external void start();
  external void stop();
  external void abort();
}

@JS('SpeechSynthesisUtterance')
extension type _Utterance._(JSObject _) implements JSObject {
  external factory _Utterance(String text);
  external set lang(String value);
  external set voice(JSObject? value);
  external set rate(num value);
  external set onend(JSFunction? value);
  external set onerror(JSFunction? value);
}

JSFunction? get _recognitionClass {
  for (final name in const ['SpeechRecognition', 'webkitSpeechRecognition']) {
    final c = globalContext[name];
    if (c != null && c.isA<JSFunction>()) return c as JSFunction;
  }
  return null;
}

JSObject? get _synth {
  final s = globalContext['speechSynthesis'];
  return s != null && s.isA<JSObject>() ? s as JSObject : null;
}

bool get canListen => _recognitionClass != null;
bool get canSpeak => _synth != null && globalContext.has('SpeechSynthesisUtterance');

/// Chrome loads its voice list lazily — ask once early so it is ready for the first answer.
void warmUp() => _voices();

_Recognition? _active;

Future<String> listen(String lang, void Function(String partial)? onPartial) {
  final cls = _recognitionClass;
  if (cls == null) return Future.error(const VoiceException('unsupported'));
  _active?.abort();

  final r = cls.callAsConstructor<_Recognition>()
    ..lang = lang
    ..interimResults = true
    ..continuous = false
    ..maxAlternatives = 1;
  final done = Completer<String>();
  var text = '';
  String? error;

  r.onresult = ((JSObject event) {
    final results = event['results'] as JSObject;
    final count = (results['length'] as JSNumber).toDartInt;
    final buffer = StringBuffer();
    for (var i = 0; i < count; i++) {
      final best = results.getProperty<JSObject>(i.toJS).getProperty<JSObject>(0.toJS);
      buffer.write((best['transcript'] as JSString).toDart);
    }
    text = buffer.toString().trim();
    onPartial?.call(text);
  }).toJS;
  r.onerror = ((JSObject event) {
    final code = event['error'];
    error = code != null && code.isA<JSString>() ? (code as JSString).toDart : 'error';
  }).toJS;
  r.onend = ((JSAny? _) {
    if (identical(_active, r)) _active = null;
    if (done.isCompleted) return;
    final e = error;
    // `aborted` = we stopped it ourselves; keep whatever was heard.
    if (e != null && e != 'aborted' && text.isEmpty) {
      done.completeError(VoiceException(e));
    } else {
      done.complete(text);
    }
  }).toJS;

  _active = r;
  try {
    r.start();
  } catch (_) {
    _active = null;
    return Future.error(const VoiceException('error'));
  }
  return done.future;
}

/// Ends listening now; the pending [listen] completes with what was heard so far.
void stopListening() => _active?.stop();

List<JSObject> _voices() {
  final synth = _synth;
  if (synth == null) return const [];
  final list = synth.callMethod<JSArray<JSObject>?>('getVoices'.toJS);
  return list?.toDart ?? const [];
}

String _voiceLang(JSObject v) {
  final l = v['lang'];
  return l != null && l.isA<JSString>() ? (l as JSString).toDart.toLowerCase().replaceAll('_', '-') : '';
}

/// Reads [text] aloud with the first of [langs] the browser has a voice for.
Future<void> speak(String text, List<String> langs) {
  final synth = _synth;
  if (synth == null || text.trim().isEmpty) return Future.value();
  synth.callMethod<JSAny?>('cancel'.toJS);

  final voices = _voices();
  JSObject? voice;
  var lang = langs.first;
  for (final l in langs) {
    final prefix = l.toLowerCase().split('-').first;
    final match = voices.where((v) => _voiceLang(v).split('-').first == prefix).firstOrNull;
    if (match != null) {
      voice = match;
      lang = l;
      break;
    }
  }

  final done = Completer<void>();
  void finish(JSAny? _) {
    if (!done.isCompleted) done.complete();
  }

  final u = _Utterance(text)
    ..lang = lang
    ..rate = 1
    ..onend = finish.toJS
    ..onerror = finish.toJS;
  if (voice != null) u.voice = voice;
  synth.callMethod<JSAny?>('speak'.toJS, u);
  return done.future;
}

void stopSpeaking() => _synth?.callMethod<JSAny?>('cancel'.toJS);
