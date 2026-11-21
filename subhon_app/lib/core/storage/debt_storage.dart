import '../../models/debt_model.dart';

/// Debts and credits, kept on this phone for each account (the API has no
/// debts yet).
abstract interface class DebtStorage {
  Future<List<DebtModel>> read(String userId);
  Future<void> write(String userId, List<DebtModel> debts);
}
