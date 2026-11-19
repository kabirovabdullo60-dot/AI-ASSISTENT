import 'package:subhon_app/core/storage/statement_history_storage.dart';
import 'package:subhon_app/models/statement_request_model.dart';

class MemoryStatementHistoryStorage implements StatementHistoryStorage {
  final Map<String, List<StatementRequestModel>> byUser = {};

  @override
  Future<List<StatementRequestModel>> read(String userId) async =>
      List.of(byUser[userId] ?? const []);

  @override
  Future<void> write(String userId, List<StatementRequestModel> items) async =>
      byUser[userId] = List.of(items);
}
