import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/storage/chat_history_storage.dart';
import '../models/conversation_summary_model.dart';
import '../services/assistant_service.dart';

/// The saved chats with the AI assistant, from the server (the same on
/// every device), most recently updated first, a page at a time; rename or
/// delete one. Chats that were kept on this phone before are moved to the
/// server once.
class ChatHistoryViewModel extends ChangeNotifier {
  ChatHistoryViewModel(this._assistant, {this.legacy, this.userId});

  final AssistantService _assistant;

  /// The chats kept on the phone by the old version; `null`: none.
  final ChatHistoryStorage? legacy;
  final String? userId;

  final List<ConversationSummaryModel> _chats = [];
  int _page = 0;
  int _pages = 1;
  bool _loading = false;
  ApiException? _error;

  List<ConversationSummaryModel> get chats => List.unmodifiable(_chats);
  bool get isLoading => _loading;
  bool get hasData => _page > 0;
  bool get hasMore => _page < _pages;
  ApiException? get error => _error;

  Future<void> load() async {
    _chats.clear();
    _page = 0;
    _pages = 1;
    await _moveFromPhone();
    await loadMore();
  }

  Future<void> loadMore() async {
    if (_loading || !hasMore) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _assistant.conversations(page: _page + 1);
      _chats.addAll(page.items);
      _page = page.page;
      _pages = page.pages;
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Returns `false` (with [error]) when the server refused it.
  Future<bool> rename(String id, String title) async {
    final text = title.trim();
    if (text.isEmpty) return false;
    try {
      final updated = await _assistant.rename(
        id,
        text.length > 80 ? text.substring(0, 80) : text,
      );
      final i = _chats.indexWhere((c) => c.id == id);
      if (i >= 0) _chats[i] = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e;
      notifyListeners();
      return false;
    }
  }

  /// Already gone on the server (404) counts as deleted.
  Future<bool> delete(String id) async {
    try {
      await _assistant.deleteConversation(id);
    } on ApiException catch (e) {
      if (e.code != 'CONVERSATION_NOT_FOUND') {
        _error = e;
        notifyListeners();
        return false;
      }
    }
    _chats.removeWhere((c) => c.id == id);
    notifyListeners();
    return true;
  }

  /// The old phone-only history goes to the server (the AI is not asked),
  /// then is forgotten on the phone. A chat that fails stays for next time.
  Future<void> _moveFromPhone() async {
    final storage = legacy;
    final user = userId;
    if (storage == null || user == null) return;
    final local = await storage.read(user);
    if (local.isEmpty) return;
    final left = [...local];
    // Oldest first, so the newest ends up on top.
    for (final chat in local.reversed) {
      if (chat.messages.isEmpty) {
        left.remove(chat);
        continue;
      }
      try {
        await _assistant.saveConversation(chat.messages);
        left.remove(chat);
      } on ApiException {
        break;
      }
    }
    await storage.write(user, left);
  }
}
