import 'package:flutter/foundation.dart';

import '../core/network/api_exception.dart';
import '../models/chat_message_model.dart';
import '../services/assistant_service.dart';

class AssistantViewModel extends ChangeNotifier {
  AssistantViewModel(this._service);

  final AssistantService _service;

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

  void clear() {
    if (_isSending) return;
    _messages.clear();
    _error = null;
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
