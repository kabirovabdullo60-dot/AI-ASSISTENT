import '../core/utils/money.dart';
import 'expense_category.dart';

/// `CategoryExpenseOut` from the API contract (API.md / Swagger).
class CategoryExpenseModel {
  const CategoryExpenseModel({required this.category, required this.total});

  factory CategoryExpenseModel.fromJson(Map<String, dynamic> json) =>
      CategoryExpenseModel(
        category: ExpenseCategory.fromJson(json['category'] as String),
        total: parseMoney(json['totalAmount'] as String),
      );

  final ExpenseCategory category;
  final double total;
}
