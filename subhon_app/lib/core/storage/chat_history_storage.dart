import '../../models/chat_conversation_model.dart';

/// Keeps the conversations with the AI assistant on the phone, separately
/// for each account ([userId]).
abstract interface class ChatHistoryStorage {
  /// Newest first.
  Future<List<ChatConversationModel>> read(String userId);
  Future<void> write(String userId, List<ChatConversationModel> chats);
}
