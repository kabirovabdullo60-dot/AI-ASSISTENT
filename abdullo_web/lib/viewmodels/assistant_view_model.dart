import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/assistant_action_model.dart';
import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';
import '../services/assistant_service.dart';
import '../services/chat_history_service.dart';

class AssistantViewModel extends ChangeNotifier {
  /// [history] saves every chat so it can be opened again from the history list.
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

  /// Saved chats, newest first.
  List<ConversationModel> get conversations => List.unmodifiable(_conversations);

  /// Id of the open saved chat; null for a new chat not yet answered.
  String? get currentId => _currentId;

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

  /// [language] = 'en' / 'ru' / 'tg' — the assistant answers in it.
  Future<void> send(String text, {String language = 'en'}) async {
    final question = text.trim();
    if (question.isEmpty || _isSending) return;

    _messages.add(ChatMessageModel(role: ChatRole.user, text: question, time: DateTime.now()));
    _isSending = true;
    _error = null;
    _rateLimited = false;
    _notify();
    try {
      final reply = await _service.sendMessage(List.of(_messages), language: language);
      _messages.add(reply);
      await _saveCurrent();
    } on ApiException catch (e) {
      _rateLimited = e.code == 'RATE_LIMITED';
      _error = 'The assistant did not answer. Please try again.';
      debugPrint('AssistantViewModel.send: $e');
    } catch (e) {
      _error = 'The assistant did not answer. Please try again.';
      debugPrint('AssistantViewModel.send: $e');
    } finally {
      _isSending = false;
      _notify();
    }
  }

  Future<void> confirmAction(String id) => _runAction(id, () => _service.confirmAction(id));

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
      await _saveCurrent();
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
    _notify();
  }

  Future<void> loadHistory() async {
    final history = _history;
    if (history == null) return;
    _conversations = await history.list();
    _notify();
  }

  /// Opens a saved chat; the next question continues it.
  void open(String id) {
    if (_isSending || id == _currentId) return;
    final c = _conversations.where((c) => c.id == id).firstOrNull;
    if (c == null) return;
    _messages
      ..clear()
      ..addAll(c.messages);
    _currentId = c.id;
    _error = null;
    _rateLimited = false;
    _notify();
  }

  Future<void> delete(String id) async {
    final history = _history;
    if (history == null) return;
    if (id == _currentId) clear();
    _conversations = await history.delete(id);
    _notify();
  }

  /// Saves the open chat after an answer: a new chat gets its first question as the title.
  Future<void> _saveCurrent() async {
    final history = _history;
    if (history == null || _messages.isEmpty) return;
    final now = DateTime.now();
    final kept = _messages.length > ConversationModel.maxMessages
        ? _messages.sublist(_messages.length - ConversationModel.maxMessages)
        : List.of(_messages);
    final existing = _conversations.where((c) => c.id == _currentId).firstOrNull;
    final conversation =
        existing?.copyWith(updatedAt: now, messages: kept) ??
        ConversationModel(
          id: 'c-${now.microsecondsSinceEpoch}',
          title: ConversationModel.titleFrom(_messages.firstWhere((m) => m.isUser).text),
          createdAt: now,
          updatedAt: now,
          messages: kept,
        );
    _currentId = conversation.id;
    _conversations = await history.save(conversation);
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
