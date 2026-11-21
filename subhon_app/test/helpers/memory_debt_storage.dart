import 'package:subhon_app/core/storage/debt_storage.dart';
import 'package:subhon_app/models/debt_model.dart';

class MemoryDebtStorage implements DebtStorage {
  final Map<String, List<DebtModel>> byUser = {};

  @override
  Future<List<DebtModel>> read(String userId) async =>
      List.of(byUser[userId] ?? const []);

  @override
  Future<void> write(String userId, List<DebtModel> debts) async =>
      byUser[userId] = List.of(debts);
}
