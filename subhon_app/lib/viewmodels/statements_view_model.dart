import 'package:flutter/foundation.dart';

import '../core/storage/statement_history_storage.dart';
import '../models/statement_request_model.dart';

/// "Выписки и справки": which tab is open, and "Мои выписки" (the
/// statements opened before on this phone).
class StatementsViewModel extends ChangeNotifier {
  StatementsViewModel(this._storage, this._userId);

  final StatementHistoryStorage _storage;
  final String? _userId;

  bool _showMine = false;
  List<StatementRequestModel> _mine = const [];

  bool get showMine => _showMine;
  List<StatementRequestModel> get mine => _mine;

  Future<void> load() async {
    final user = _userId;
    _mine = user == null ? const [] : await _storage.read(user);
    notifyListeners();
  }

  void showTab({required bool mine}) {
    _showMine = mine;
    notifyListeners();
    if (mine) load();
  }
}
