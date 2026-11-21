import '../core/utils/local_date.dart';
import 'expense_category.dart';

/// `ExpenseUpdate` from the API contract (API.md / Swagger).
class ExpenseUpdateModel {
  const ExpenseUpdateModel({
    this.storeId,
    this.category,
    this.amount,
    this.expenseDate,
    this.description,
  });

  final String? storeId;
  final ExpenseCategory? category;
  final double? amount;
  final DateTime? expenseDate;
  final String? description;

  /// Fields sent as `null` to clear them: `storeId: null` makes it an
  /// expense of the whole business.
  static const clearable = {'storeId', 'description'};

  /// PUT updates only the fields that are sent: a field left `null`
  /// is not sent, unless it is listed in [clear] (then it is cleared).
  Map<String, dynamic> toJson({Set<String> clear = const {}}) => {
    if (storeId != null || clear.contains('storeId')) 'storeId': storeId,
    if (category != null) 'category': category!.json,
    if (amount != null) 'amount': amount!.toStringAsFixed(2),
    if (expenseDate != null) 'expenseDate': formatLocalDate(expenseDate!),
    if (description != null || clear.contains('description'))
      'description': description,
  };
}
