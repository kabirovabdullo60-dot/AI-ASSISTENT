import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/navigation/app_section.dart';
import '../core/voice/voice_command.dart';
import '../models/chat_message_model.dart';
import '../services/preferences_service.dart';
import '../services/voice_service.dart';
import 'assistant_view_model.dart';
import 'home_view_model.dart';

/// What the voice pill shows right now.
enum VoiceStatus { idle, listening, opened, failed }

/// Voice control: listen → open a page / start a new chat / ask the AI, then read the answer aloud.
class VoiceViewModel extends ChangeNotifier {
  VoiceViewModel(this._voice, this._home, this._assistant, this._prefs) {
    _prefs.loadVoiceReplies().then((on) {
      _speakReplies = on;
      _notify();
    });
  }

  final VoiceService _voice;
  final HomeViewModel _home;
  final AssistantViewModel _assistant;
  final PreferencesService _prefs;

  VoiceStatus _status = VoiceStatus.idle;
  String _heard = '';
  String? _errorCode;
  AppSection? _opened;
  bool _speaking = false;
  bool _speakReplies = true;
  bool _disposed = false;
  Timer? _hideTimer;

  bool get canListen => _voice.canListen;
  bool get canSpeak => _voice.canSpeak;
  VoiceStatus get status => _status;
  bool get isListening => _status == VoiceStatus.listening;
  bool get isSpeaking => _speaking;
  bool get speakReplies => _speakReplies;

  /// Text heard so far (live while listening).
  String get heard => _heard;

  /// [VoiceException.code] when [status] is [VoiceStatus.failed].
  String? get errorCode => _errorCode;

  /// Page opened by the last command, when [status] is [VoiceStatus.opened].
  AppSection? get opened => _opened;

  /// Mic button: starts listening, or stops it if already listening.
  Future<void> toggleListening({required String language}) async {
    if (isListening) {
      _voice.stopListening();
      return;
    }
    _hideTimer?.cancel();
    stopSpeaking();
    _status = VoiceStatus.listening;
    _heard = '';
    _errorCode = null;
    _notify();
    try {
      final text = await _voice.listen(
        language: language,
        onPartial: (t) {
          _heard = t;
          _notify();
        },
      );
      _heard = text;
      _status = VoiceStatus.idle;
      _notify();
      if (text.trim().isNotEmpty) await _handle(text, language);
    } on VoiceException catch (e) {
      _fail(e.code);
    } catch (e) {
      debugPrint('VoiceViewModel.listen: $e');
      _fail('error');
    }
  }

  Future<void> _handle(String text, String language) async {
    switch (VoiceCommand.parse(text)) {
      case OpenSection(:final section):
        _home.select(section);
        _opened = section;
        _show(VoiceStatus.opened);
      case NewChat():
        _assistant.clear();
        _home.select(AppSection.assistant);
        _opened = AppSection.assistant;
        _show(VoiceStatus.opened);
      case StopSpeaking():
        stopSpeaking();
      case AskAssistant(:final question):
        _home.select(AppSection.assistant);
        final before = _assistant.messages.length;
        await _assistant.send(question, language: language);
        final messages = _assistant.messages;
        // Only our own answer: one question + one reply were added.
        if (_speakReplies && messages.length == before + 2 && messages.last.role == ChatRole.assistant) {
          await speak(messages.last.text, language: language);
        }
    }
  }

  Future<void> speak(String text, {required String language}) async {
    if (!canSpeak || _disposed) return;
    _speaking = true;
    _notify();
    try {
      await _voice.speak(text, language: language);
    } catch (e) {
      debugPrint('VoiceViewModel.speak: $e');
    } finally {
      _speaking = false;
      _notify();
    }
  }

  void stopSpeaking() {
    if (!_speaking) return;
    _voice.stopSpeaking();
    _speaking = false;
    _notify();
  }

  void toggleSpeakReplies() {
    _speakReplies = !_speakReplies;
    if (!_speakReplies) stopSpeaking();
    _prefs.saveVoiceReplies(_speakReplies);
    _notify();
  }

  /// Hides the pill (tap on it).
  void dismiss() {
    _hideTimer?.cancel();
    if (isListening) return;
    _status = VoiceStatus.idle;
    _notify();
  }

  void _fail(String code) {
    _errorCode = code;
    _show(VoiceStatus.failed, seconds: 5);
  }

  void _show(VoiceStatus status, {int seconds = 3}) {
    _status = status;
    _notify();
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: seconds), dismiss);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _hideTimer?.cancel();
    _voice.stopListening();
    _voice.stopSpeaking();
    super.dispose();
  }
}
