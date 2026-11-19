import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/chat_message_model.dart';
import '../services/assistant_service.dart';

/// The conversation with the AI assistant (kept while the screen is open).
/// A question that failed stays in the list and can be sent again.
class ChatViewModel extends ChangeNotifier {
  ChatViewModel(this._assistant, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AssistantService _assistant;
  final DateTime Function() _clock;

  /// The API accepts 1–2000 characters per message.
  static const int maxLength = 2000;

  final List<ChatMessageModel> _messages = [];
  bool _isSending = false;
  ApiException? _error;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;

  /// Why the last question got no answer; `null` otherwise.
  ApiException? get error => _error;

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
    _messages.add(
      ChatMessageModel(fromUser: true, text: question, time: _clock()),
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
}
