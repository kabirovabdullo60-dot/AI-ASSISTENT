import 'package:subhon_app/core/storage/personal_finance_storage.dart';
import 'package:subhon_app/models/personal_finance_model.dart';

class MemoryPersonalFinanceStorage implements PersonalFinanceStorage {
  final Map<String, PersonalFinanceModel> byUser = {};

  @override
  Future<PersonalFinanceModel> read(String userId) async =>
      byUser[userId] ?? const PersonalFinanceModel();

  @override
  Future<void> write(String userId, PersonalFinanceModel data) async =>
      byUser[userId] = data;
}
