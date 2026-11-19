import '../core/utils/local_date.dart';
import 'expense_category.dart';

/// `ExpenseCreate` from the API contract (API.md / Swagger).
class ExpenseCreateModel {
  const ExpenseCreateModel({
    required this.category,
    required this.amount,
    this.storeId,
    this.expenseDate,
    this.description,
  });

  /// `null`: the whole business.
  final String? storeId;
  final ExpenseCategory category;
  final double amount;
  final DateTime? expenseDate;
  final String? description;

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'category': category.json,
    'amount': amount.toStringAsFixed(2),
    if (expenseDate != null) 'expenseDate': formatLocalDate(expenseDate!),
    'description': ?description,
  };
}
