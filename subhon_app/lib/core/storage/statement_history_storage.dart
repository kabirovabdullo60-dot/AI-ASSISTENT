import '../../models/statement_request_model.dart';

/// "Мои выписки": the statements opened on this phone, per account.
abstract interface class StatementHistoryStorage {
  /// Newest first.
  Future<List<StatementRequestModel>> read(String userId);
  Future<void> write(String userId, List<StatementRequestModel> items);
}
