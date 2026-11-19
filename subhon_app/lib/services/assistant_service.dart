import '../core/network/api_client.dart';
import '../models/chat_message_model.dart';

/// `Assistant` (API.md): the AI business assistant, answering about the
/// business's own figures in en / ru / tg.
class AssistantService {
  AssistantService(this._api);

  final ApiClient _api;

  /// The server uses only the last 20 messages.
  static const int historyLimit = 20;

  /// An answer usually takes a few seconds, at most about 60.
  static const Duration timeout = Duration(seconds: 75);

  /// [messages]: oldest first, ending with the user's new question.
  Future<ChatMessageModel> chat({
    required String language,
    required List<ChatMessageModel> messages,
  }) async {
    final recent = messages.length > historyLimit
        ? messages.sublist(messages.length - historyLimit)
        : messages;
    return ChatMessageModel.fromJson(
      await _api.post(
            '/api/assistant/chat',
            body: {
              'language': language,
              'messages': [for (final m in recent) m.toJson()],
            },
            timeout: timeout,
          )
          as Map<String, dynamic>,
    );
  }
}
