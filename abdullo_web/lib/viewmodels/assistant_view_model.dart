import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../core/utils/language_detect.dart';
import '../models/assistant_action_model.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../services/assistant_service.dart';
import '../services/chat_history_service.dart';

class AssistantViewModel extends ChangeNotifier {
  /// [history] = saved chats on the server (the chat endpoint saves them itself).
  /// [onDataChanged] runs after a confirmed action changed data, so the pages reload.
  AssistantViewModel(this._service, {this._history, this.onDataChanged}) {
    loadHistory();
  }

  final AssistantService _service;
  final ChatHistoryService? _history;
  final void Function(AssistantActionModel action)? onDataChanged;

  final Set<String> _busyActions = {};
  final Map<String, String> _actionErrors = {};

  /// Confirm / cancel of this action is running.
  bool isActionBusy(String id) => _busyActions.contains(id);

  /// Error code when the last confirm / cancel request failed (e.g. NETWORK_ERROR).
  String? actionError(String id) => _actionErrors[id];

  List<ConversationModel> _conversations = [];
  String? _currentId;
  String? _openingId;

  /// Saved chats, newest first (without their messages).
  List<ConversationModel> get conversations => List.unmodifiable(_conversations);

  /// Id of the open saved chat; null for a new chat not yet answered.
  String? get currentId => _currentId;

  /// A saved chat is being loaded.
  String? get openingId => _openingId;

  final List<ChatMessageModel> _messages = [];
  bool _isSending = false;
  String? _error;
  bool _disposed = false;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get error => _error;

  /// True when the backend said `429 RATE_LIMITED` (too many questions).
  bool get rateLimited => _rateLimited;
  bool _rateLimited = false;

  /// With [rateLimited]: seconds to wait (`Retry-After`), when the server said.
  int? get retryAfter => _retryAfter;
  int? _retryAfter;

  /// The assistant answers in the language the question is written in (Russian, English, or
  /// Tajik in Cyrillic or Latin letters); [language] (the site's) is used only when the
  /// question is too short to tell.
  Future<void> send(String text, {String language = 'en'}) async {
    final question = text.trim();
    if (question.isEmpty || _isSending) return;
    language = detectMessageLanguage(question) ?? language;

    _messages.add(ChatMessageModel(role: ChatRole.user, text: question, time: DateTime.now()));
    _isSending = true;
    _error = null;
    _rateLimited = false;
    _retryAfter = null;
    _notify();
    try {
      ({ChatMessageModel reply, String? conversationId}) answer;
      try {
        answer = await _service.sendMessage(List.of(_messages), language: language, conversationId: _currentId);
      } on ApiException catch (e) {
        // The open chat was deleted elsewhere → continue as a new chat.
        if (e.code != 'CONVERSATION_NOT_FOUND') rethrow;
        answer = await _service.sendMessage(List.of(_messages), language: language);
      }
      _messages.add(answer.reply);
      _currentId = answer.conversationId ?? _currentId;
      // The answer shows now; the history list (new title / order) refreshes behind it.
      unawaited(loadHistory());
    } on ApiException catch (e) {
      _rateLimited = e.code == 'RATE_LIMITED';
      _retryAfter = e.retryAfter;
      _error = e.code;
      debugPrint('AssistantViewModel.send: $e');
    } catch (e) {
      _error = 'NETWORK_ERROR';
      debugPrint('AssistantViewModel.send: $e');
    } finally {
      _isSending = false;
      _notify();
    }
  }

  /// Runs a proposed (or failed) action. [params] = only the fields the user corrected.
  Future<void> confirmAction(String id, {Map<String, dynamic>? params}) =>
      _runAction(id, () => _service.confirmAction(id, params: params));

  Future<void> cancelAction(String id) => _runAction(id, () => _service.cancelAction(id));

  Future<void> _runAction(String id, Future<AssistantActionModel> Function() request) async {
    if (_busyActions.contains(id)) return;
    _busyActions.add(id);
    _actionErrors.remove(id);
    _notify();
    try {
      final action = await request();
      _replaceAction(action);
      if (action.status == ActionStatus.done) onDataChanged?.call(action);
    } on ApiException catch (e) {
      debugPrint('AssistantViewModel action $id: $e');
      if (e.code == 'ACTION_EXPIRED') {
        _setStatus(id, ActionStatus.expired);
      } else if (e.code == 'ACTION_ALREADY_HANDLED') {
        // Handled elsewhere (another tab, the phone) → show what really happened.
        try {
          _replaceAction(await _service.getAction(id));
        } catch (_) {
          _actionErrors[id] = e.code;
        }
      } else {
        _actionErrors[id] = e.code;
      }
    } catch (e) {
      debugPrint('AssistantViewModel action $id: $e');
      _actionErrors[id] = 'NETWORK_ERROR';
    } finally {
      _busyActions.remove(id);
      _notify();
    }
  }

  void _setStatus(String id, ActionStatus status) {
    for (final m in _messages) {
      for (final a in m.actions) {
        if (a.id == id) return _replaceAction(a.copyWith(status: status));
      }
    }
  }

  void _replaceAction(AssistantActionModel action) {
    for (var i = 0; i < _messages.length; i++) {
      final actions = _messages[i].actions;
      final j = actions.indexWhere((a) => a.id == action.id);
      if (j < 0) continue;
      _messages[i] = _messages[i].copyWith(actions: [...actions]..[j] = action);
      return;
    }
  }

  /// Starts a new chat (the current one stays in the history).
  void clear() {
    if (_isSending) return;
    _messages.clear();
    _currentId = null;
    _error = null;
    _rateLimited = false;
    _retryAfter = null;
    _notify();
  }

  bool _imported = false;

  /// Reloads the chat list. The first time it also uploads chats an older version kept
  /// in this browser.
  Future<void> loadHistory() async {
    final history = _history;
    if (history == null) return;
    try {
      if (!_imported) {
        _imported = true;
        await history.importLocal();
      }
      _conversations = await history.list();
      _notify();
    } catch (e) {
      // Offline: keep the list we have; the chat itself still works.
      debugPrint('AssistantViewModel.loadHistory: $e');
    }
  }

  /// Opens a saved chat (its actions show their current status); the next question continues it.
  Future<void> open(String id) async {
    final history = _history;
    if (history == null || _isSending || id == _currentId || _openingId != null) return;
    _openingId = id;
    _notify();
    try {
      final c = await history.get(id);
      _messages
        ..clear()
        ..addAll(c.messages);
      _currentId = c.id;
      _error = null;
      _rateLimited = false;
    } on ApiException catch (e) {
      debugPrint('AssistantViewModel.open: $e');
      if (e.code == 'CONVERSATION_NOT_FOUND') {
        _conversations = _conversations.where((c) => c.id != id).toList();
      } else {
        _error = e.code;
      }
    } catch (e) {
      debugPrint('AssistantViewModel.open: $e');
      _error = 'NETWORK_ERROR';
    } finally {
      _openingId = null;
      _notify();
    }
  }

  Future<void> delete(String id) async {
    final history = _history;
    if (history == null) return;
    try {
      await history.delete(id);
    } on ApiException catch (e) {
      if (e.code != 'CONVERSATION_NOT_FOUND') {
        _error = e.code;
        _notify();
        return;
      }
    } catch (_) {
      _error = 'NETWORK_ERROR';
      _notify();
      return;
    }
    if (id == _currentId) clear();
    _conversations = _conversations.where((c) => c.id != id).toList();
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
