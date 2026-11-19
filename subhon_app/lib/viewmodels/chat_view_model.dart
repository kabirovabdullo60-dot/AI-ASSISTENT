import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/utils/question_helper.dart';
import '../models/chat_message_model.dart';
import '../services/assistant_service.dart';
import '../services/voice_service.dart';

/// Where the voice conversation is.
enum VoiceState { off, listening, thinking, speaking }

/// The conversation with the AI assistant (kept while the screen is open),
/// typed or by voice. Short requests ("сотрудники") are sent as clear
/// questions. A question that failed stays in the list and can be sent
/// again.
class ChatViewModel extends ChangeNotifier {
  ChatViewModel(this._assistant, {this.voice, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AssistantService _assistant;

  /// Speech in and out; `null`: typing only.
  final VoiceService? voice;
  final DateTime Function() _clock;

  VoiceState _voiceState = VoiceState.off;
  bool _voiceOn = false;
  String _heard = '';
  bool _voiceUnavailable = false;
  bool _disposed = false;

  /// The API accepts 1–2000 characters per message.
  static const int maxLength = 2000;

  final List<ChatMessageModel> _messages = [];
  bool _isSending = false;
  ApiException? _error;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;

  /// Why the last question got no answer; `null` otherwise.
  ApiException? get error => _error;

  /// Voice: what is happening, the words heard so far, and whether the
  /// phone can't recognise speech (no permission or not supported).
  VoiceState get voiceState => _voiceState;
  String get heard => _heard;
  bool get voiceUnavailable => _voiceUnavailable;
  bool get hasVoice => voice != null;

  /// The last answer of the assistant, if any.
  ChatMessageModel? get lastAnswer =>
      _messages.where((m) => !m.fromUser).lastOrNull;

  /// The last question had no answer: it can be sent again.
  bool get canRetry =>
      _error != null && _messages.isNotEmpty && _messages.last.fromUser;

  /// Sends [text] in [language] (`en` / `ru` / `tg`); `false` when nothing
  /// was sent (empty, too long or already waiting).
  Future<bool> send(String text, String language) async {
    final question = text.trim();
    if (question.isEmpty || question.length > maxLength || _isSending) {
      return false;
    }
    final prompt = expandQuestion(question, language);
    _messages.add(
      ChatMessageModel(
        fromUser: true,
        text: question,
        time: _clock(),
        prompt: prompt == question ? null : prompt,
      ),
    );
    await _ask(language);
    return true;
  }

  /// Sends the unanswered last question again.
  Future<void> retry(String language) async {
    if (!canRetry || _isSending) return;
    await _ask(language);
  }

  Future<void> _ask(String language) async {
    _isSending = true;
    _error = null;
    notifyListeners();
    try {
      final reply = await _assistant.chat(
        language: language,
        messages: _messages,
      );
      _messages.add(reply);
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Starts talking by voice: listen → answer → read it aloud → listen
  /// again, until [stopVoice].
  Future<void> startVoice(String language) async {
    final speech = voice;
    if (speech == null) return;
    _voiceOn = true;
    _voiceUnavailable = false;
    await speech.stopSpeaking();
    await _listen(language);
  }

  /// Ends the voice conversation (the messages stay). [notify] `false`
  /// when the voice screen is being closed (nothing may rebuild then).
  Future<void> stopVoice({bool notify = true}) async {
    _voiceOn = false;
    if (notify) {
      _setVoice(VoiceState.off);
    } else {
      _voiceState = VoiceState.off;
    }
    await voice?.stopListening();
    await voice?.stopSpeaking();
  }

  Future<void> _listen(String language) async {
    if (!_voiceOn) return;
    _heard = '';
    _setVoice(VoiceState.listening);
    var handled = false;
    final ok = await voice!.listen(
      language: language,
      onWords: (words, done) {
        if (handled) return;
        _heard = words;
        notifyListeners();
        if (done) {
          handled = true;
          _answerAloud(words, language);
        }
      },
      onStop: () {
        if (handled || _voiceState != VoiceState.listening) return;
        handled = true;
        // Silence: wait for a tap on the microphone.
        _setVoice(VoiceState.off);
      },
    );
    if (!ok) {
      _voiceOn = false;
      _voiceUnavailable = true;
      _setVoice(VoiceState.off);
    }
  }

  Future<void> _answerAloud(String words, String language) async {
    if (words.trim().isEmpty) {
      _setVoice(VoiceState.off);
      return;
    }
    _setVoice(VoiceState.thinking);
    final before = _messages.length;
    await send(words, language);
    if (!_voiceOn || _disposed) return;
    final answered = _messages.length > before + 1 && !_messages.last.fromUser;
    if (!answered) {
      _setVoice(VoiceState.off);
      return;
    }
    _setVoice(VoiceState.speaking);
    await voice!.speak(_messages.last.text, language);
    if (_voiceOn && !_disposed) await _listen(language);
  }

  void _setVoice(VoiceState state) {
    if (_disposed) return;
    _voiceState = state;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _voiceOn = false;
    voice?.stopListening();
    voice?.stopSpeaking();
    super.dispose();
  }
}
