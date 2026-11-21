import '../../models/personal_finance_model.dart';

/// The personal accountant's data, on this phone for each account.
abstract interface class PersonalFinanceStorage {
  Future<PersonalFinanceModel> read(String userId);
  Future<void> write(String userId, PersonalFinanceModel data);
}
