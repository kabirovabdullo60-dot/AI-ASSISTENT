import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/utils/language_detector.dart';
import '../core/utils/question_helper.dart';
import '../models/assistant_action_model.dart';
import '../models/assistant_action_status.dart';
import '../models/chat_message_model.dart';
import '../services/assistant_service.dart';
import '../services/voice_service.dart';

/// Where the voice conversation is.
enum VoiceState { off, listening, thinking, speaking }

/// The conversation with the AI assistant, typed or by voice. Chats are
/// saved on the server ([conversationId] from each reply continues one).
/// The answer comes in the language the question is written in. A reply
/// may propose changes ([AssistantActionModel]) that run only when the
/// person confirms them. A question that failed can be sent again.
class ChatViewModel extends ChangeNotifier {
  ChatViewModel(
    this._assistant, {
    this.voice,
    this.userId,
    this.personalContext,
    this.onDataChanged,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// My personal finances (kept on the phone) as a short note added before
  /// the newest question only, so the assistant can answer about them.
  final String? Function()? personalContext;

  /// A confirmed change (DONE): the other screens reload.
  final VoidCallback? onDataChanged;

  final AssistantService _assistant;

  /// Speech in and out; `null`: typing only.
  final VoiceService? voice;
  final DateTime Function() _clock;
  final String? userId;

  /// The API accepts 1–2000 characters per message.
  static const int maxLength = 2000;

  final List<ChatMessageModel> _messages = [];
  String? _conversationId;
  bool _isSending = false;
  bool _isOpening = false;
  ApiException? _error;
  String _language = 'ru';
  DateTime? _waitUntil;
  Timer? _waitTimer;

  /// Actions with a request on its way (both buttons disabled).
  final Set<String> _busyActions = {};

  /// Why the last confirm / cancel of an action failed (translated in the
  /// view).
  final Map<String, ApiException> _actionErrors = {};

  VoiceState _voiceState = VoiceState.off;
  bool _voiceOn = false;
  String _heard = '';
  bool _voiceUnavailable = false;
  bool _micFailed = false;
  bool _disposed = false;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;

  /// A saved chat is being loaded.
  bool get isOpening => _isOpening;

  /// Why the last question got no answer; `null` otherwise.
  ApiException? get error => _error;

  /// The language of the last question (the answer is in it).
  String get language => _language;

  /// 429: seconds until the next question may be sent; 0 when it can.
  int get waitSeconds {
    final until = _waitUntil;
    if (until == null) return 0;
    final left = until.difference(_clock()).inMilliseconds;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }

  bool get canSend => !_isSending && !_isOpening && waitSeconds == 0;

  bool isActionBusy(String id) => _busyActions.contains(id);
  ApiException? actionError(String id) => _actionErrors[id];

  /// Voice: what is happening, the words heard so far, and whether the
  /// phone can't recognise speech (no permission or not supported).
  VoiceState get voiceState => _voiceState;
  String get heard => _heard;
  bool get voiceUnavailable => _voiceUnavailable;

  /// The microphone stopped at once (no audio input, a recognizer error).
  bool get micFailed => _micFailed;
  bool get hasVoice => voice != null;

  /// The last answer of the assistant, if any.
  ChatMessageModel? get lastAnswer =>
      _messages.where((m) => !m.fromUser).lastOrNull;

  /// The saved conversation shown now; `null` for a new one.
  String? get conversationId => _conversationId;

  /// Starts a new, empty conversation (the current one stays saved).
  Future<void> newChat() async {
    await stopVoice();
    _messages.clear();
    _conversationId = null;
    _error = null;
    _actionErrors.clear();
    notifyListeners();
  }

  /// Opens a saved chat from the server; new questions continue it. The
  /// actions show their current status.
  Future<void> open(String id) async {
    await stopVoice();
    _isOpening = true;
    _error = null;
    notifyListeners();
    try {
      final (_, messages) = await _assistant.conversation(id);
      _messages
        ..clear()
        ..addAll(messages);
      _conversationId = id;
      _actionErrors.clear();
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isOpening = false;
      notifyListeners();
    }
  }

  /// The open chat was deleted (from the history, or on another device):
  /// the next question starts a new one.
  void forget(String id) {
    if (_conversationId == id) _conversationId = null;
  }

  /// The last question had no answer: it can be sent again.
  bool get canRetry =>
      _error != null && _messages.isNotEmpty && _messages.last.fromUser;

  /// Sends [text]; the answer comes in the language it is written in
  /// ([appLanguage] when too short to tell). `false` when nothing was sent
  /// (empty, too long, waiting).
  Future<bool> send(String text, String appLanguage) async {
    final question = text.trim();
    if (question.isEmpty || question.length > maxLength || !canSend) {
      return false;
    }
    _language = detectLanguage(question, appLanguage);
    final prompt = expandQuestion(question, _language);
    _messages.add(
      ChatMessageModel(
        fromUser: true,
        text: question,
        time: _clock(),
        prompt: prompt == question ? null : prompt,
      ),
    );
    await _ask();
    return true;
  }

  /// Sends the unanswered last question again.
  Future<void> retry([String? _]) async {
    if (!canRetry || !canSend) return;
    await _ask();
  }

  Future<void> _ask() async {
    _isSending = true;
    _error = null;
    notifyListeners();
    try {
      await _askOnce();
    } on ApiException catch (e) {
      if (e.code == 'CONVERSATION_NOT_FOUND' && _conversationId != null) {
        // The chat was deleted meanwhile: continue in a new one.
        _conversationId = null;
        try {
          await _askOnce();
        } on ApiException catch (again) {
          _fail(again);
        }
      } else {
        _fail(e);
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> _askOnce() async {
    final reply = await _assistant.chat(
      language: _language,
      messages: _withContext(),
      conversationId: _conversationId,
    );
    _conversationId = reply.conversationId;
    _messages.add(reply.message);
  }

  void _fail(ApiException e) {
    _error = e;
    if (e.code == 'RATE_LIMITED') {
      final seconds = e.meta['retryAfter'];
      if (seconds is num && seconds > 0) {
        _waitUntil = _clock().add(
          Duration(milliseconds: (seconds * 1000).ceil()),
        );
        _waitTimer?.cancel();
        _waitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (waitSeconds == 0) {
            t.cancel();
            _waitUntil = null;
          }
          notifyListeners();
        });
      }
    }
  }

  /// The conversation with the personal note before the last question
  /// (left out when it would be too long for the API).
  List<ChatMessageModel> _withContext() {
    final note = personalContext?.call();
    final last = _messages.lastOrNull;
    if (note == null || last == null || !last.fromUser) return _messages;
    final question = '$note\n${last.prompt ?? last.text}';
    if (question.length > maxLength) return _messages;
    return [
      ..._messages.take(_messages.length - 1),
      ChatMessageModel(
        fromUser: true,
        text: last.text,
        time: last.time,
        prompt: question,
      ),
    ];
  }

  // Actions the assistant proposed.

  /// Runs the change. DONE → the other screens reload; FAILED → the reason
  /// shows and it can be confirmed again.
  Future<void> confirmAction(String id) =>
      _handle(id, () => _assistant.confirm(id));

  Future<void> cancelAction(String id) =>
      _handle(id, () => _assistant.cancel(id));

  Future<void> _handle(
    String id,
    Future<AssistantActionModel> Function() request,
  ) async {
    if (_busyActions.contains(id)) return;
    _busyActions.add(id);
    _actionErrors.remove(id);
    notifyListeners();
    try {
      final action = await request();
      _replace(action);
      if (action.status == AssistantActionStatus.done) onDataChanged?.call();
    } on ApiException catch (e) {
      if (e.code == 'ACTION_ALREADY_HANDLED' || e.code == 'ACTION_EXPIRED') {
        // Show what really happened to it.
        try {
          _replace(await _assistant.action(id));
        } on ApiException {
          if (e.code == 'ACTION_EXPIRED') {
            _setStatus(id, AssistantActionStatus.expired);
          }
          _actionErrors[id] = e;
        }
      } else {
        _actionErrors[id] = e;
      }
    } finally {
      _busyActions.remove(id);
      notifyListeners();
    }
  }

  void _replace(AssistantActionModel action) {
    for (var i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      if (m.actions.any((a) => a.id == action.id)) {
        _messages[i] = m.withActions([
          for (final a in m.actions) a.id == action.id ? action : a,
        ]);
      }
    }
  }

  void _setStatus(String id, AssistantActionStatus status) {
    for (final m in _messages) {
      for (final a in m.actions) {
        if (a.id == id) _replace(a.copyWith(status: status));
      }
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
    _micFailed = false;
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
      onStop: (failed) {
        if (handled || _voiceState != VoiceState.listening) return;
        handled = true;
        // Silence or a failure: wait for a tap on the microphone.
        _micFailed = failed;
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
    final answerLanguage = _language;
    if (!_voiceOn || _disposed) return;
    final answered = _messages.length > before + 1 && !_messages.last.fromUser;
    if (!answered) {
      _setVoice(VoiceState.off);
      return;
    }
    _setVoice(VoiceState.speaking);
    await voice!.speak(_messages.last.text, answerLanguage);
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
    _waitTimer?.cancel();
    _voiceOn = false;
    voice?.stopListening();
    voice?.stopSpeaking();
    super.dispose();
  }
}
