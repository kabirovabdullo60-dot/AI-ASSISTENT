import '../core/network/api_client.dart';
import '../models/assistant_action_model.dart';
import '../models/chat_message_model.dart';
import '../models/chat_reply_model.dart';
import '../models/conversation_summary_model.dart';
import '../models/page_model.dart';

/// `Assistant` (API.md): the AI assistant — answers about the business's
/// own figures in en / ru / tg, keeps the chats on the server, and
/// proposes changes that run only when the person confirms them.
class AssistantService {
  AssistantService(this._api);

  final ApiClient _api;

  /// The server uses only the last 20 messages.
  static const int historyLimit = 20;

  /// An answer takes 3–60 s; the client waits at least 70 s.
  static const Duration timeout = Duration(seconds: 75);

  /// [messages]: oldest first, ending with the new question.
  /// [conversationId]: the chat to continue; `null` saves a new one.
  Future<ChatReplyModel> chat({
    required String language,
    required List<ChatMessageModel> messages,
    String? conversationId,
  }) async {
    final recent = messages.length > historyLimit
        ? messages.sublist(messages.length - historyLimit)
        : messages;
    return ChatReplyModel.fromJson(
      await _api.post(
            '/api/assistant/chat',
            body: {
              'language': language,
              'messages': [for (final m in recent) m.toJson()],
              'conversationId': ?conversationId,
            },
            timeout: timeout,
          )
          as Map<String, dynamic>,
    );
  }

  /// The saved chats, most recently updated first.
  Future<PageModel<ConversationSummaryModel>> conversations({
    int page = 1,
    int limit = 20,
  }) async => PageModel.fromJson(
    await _api.get(
          '/api/assistant/conversations',
          query: {'page': page, 'limit': limit},
        )
        as Map<String, dynamic>,
    ConversationSummaryModel.fromJson,
  );

  /// One chat with its messages (oldest first) and their actions in their
  /// current status.
  Future<(ConversationSummaryModel, List<ChatMessageModel>)> conversation(
    String id,
  ) async {
    final json =
        await _api.get('/api/assistant/conversations/$id')
            as Map<String, dynamic>;
    return (
      ConversationSummaryModel.fromJson(json),
      [
        for (final m in json['messages'] as List<dynamic>)
          ChatMessageModel.fromJson(m as Map<String, dynamic>),
      ],
    );
  }

  /// Saves a chat without asking the AI (moving the chats that were kept
  /// on the phone before history lived on the server).
  Future<String> saveConversation(List<ChatMessageModel> messages) async {
    final json =
        await _api.post(
              '/api/assistant/conversations',
              body: {
                'messages': [
                  for (final m in messages.take(200))
                    if (m.text.isNotEmpty)
                      {
                        'role': m.fromUser ? 'user' : 'assistant',
                        'text': m.text.length > 2000
                            ? m.text.substring(0, 2000)
                            : m.text,
                        if (m.time != null)
                          'time': m.time!.toUtc().toIso8601String(),
                      },
                ],
              },
            )
            as Map<String, dynamic>;
    return json['id'] as String;
  }

  Future<ConversationSummaryModel> rename(String id, String title) async =>
      ConversationSummaryModel.fromJson(
        await _api.patch(
              '/api/assistant/conversations/$id',
              body: {'title': title},
            )
            as Map<String, dynamic>,
      );

  Future<void> deleteConversation(String id) =>
      _api.delete('/api/assistant/conversations/$id');

  Future<AssistantActionModel> action(String id) async =>
      AssistantActionModel.fromJson(
        await _api.get('/api/assistant/actions/$id') as Map<String, dynamic>,
      );

  /// Runs the proposed change (with the fields the person corrected).
  Future<AssistantActionModel> confirm(
    String id, {
    Map<String, dynamic>? params,
  }) async => AssistantActionModel.fromJson(
    await _api.post(
          '/api/assistant/actions/$id/confirm',
          body: params == null ? null : {'params': params},
        )
        as Map<String, dynamic>,
  );

  Future<AssistantActionModel> cancel(String id) async =>
      AssistantActionModel.fromJson(
        await _api.post('/api/assistant/actions/$id/cancel')
            as Map<String, dynamic>,
      );
}
