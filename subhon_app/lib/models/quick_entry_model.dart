import 'money_category.dart';
import 'money_transaction_kind.dart';

/// An operation understood from a short phrase ("такси 50", "получил
/// зарплату 3000 на карту"): ready to be written or opened in the form.
class QuickEntryModel {
  const QuickEntryModel({
    required this.kind,
    this.amount,
    this.category,
    this.accountId,
    this.note,
  });

  final MoneyTransactionKind kind;

  /// `null` when no number was found.
  final double? amount;
  final MoneyCategory? category;
  final String? accountId;
  final String? note;

  /// Enough to be written straight away.
  bool get isComplete => amount != null && amount! > 0 && category != null;
}
