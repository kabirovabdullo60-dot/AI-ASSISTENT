import 'package:subhon_app/core/storage/chat_history_storage.dart';
import 'package:subhon_app/models/chat_conversation_model.dart';

/// Chat history in memory, for tests.
class MemoryChatHistoryStorage implements ChatHistoryStorage {
  final Map<String, List<ChatConversationModel>> byUser = {};

  @override
  Future<List<ChatConversationModel>> read(String userId) async =>
      List.of(byUser[userId] ?? const []);

  @override
  Future<void> write(String userId, List<ChatConversationModel> chats) async =>
      byUser[userId] = List.of(chats);
}
