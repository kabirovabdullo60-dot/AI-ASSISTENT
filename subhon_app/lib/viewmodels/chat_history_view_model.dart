import 'package:flutter/foundation.dart';

import '../core/storage/chat_history_storage.dart';
import '../models/chat_conversation_model.dart';

/// The saved conversations with the AI assistant, newest first; delete one
/// or all.
class ChatHistoryViewModel extends ChangeNotifier {
  ChatHistoryViewModel(this._storage, this._userId);

  final ChatHistoryStorage _storage;
  final String _userId;

  List<ChatConversationModel> _chats = const [];
  bool _loaded = false;

  List<ChatConversationModel> get chats => _chats;
  bool get hasData => _loaded;

  Future<void> load() async {
    _chats = await _storage.read(_userId);
    _loaded = true;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _chats = [
      for (final c in _chats)
        if (c.id != id) c,
    ];
    notifyListeners();
    await _storage.write(_userId, _chats);
  }

  Future<void> deleteAll() async {
    _chats = const [];
    notifyListeners();
    await _storage.write(_userId, _chats);
  }
}
