import 'chat_message_model.dart';

/// `ChatReplyOut`: the answer and the saved conversation it belongs to.
class ChatReplyModel {
  const ChatReplyModel({required this.message, required this.conversationId});

  factory ChatReplyModel.fromJson(Map<String, dynamic> json) => ChatReplyModel(
    message: ChatMessageModel.fromJson(json),
    conversationId: json['conversationId'] as String,
  );

  final ChatMessageModel message;

  /// Sent with the next question to continue the same chat.
  final String conversationId;
}
