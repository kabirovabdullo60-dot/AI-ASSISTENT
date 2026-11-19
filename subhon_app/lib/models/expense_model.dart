import '../core/utils/local_date.dart';
import '../core/utils/money.dart';
import 'expense_category.dart';

/// `ExpenseOut` from the API contract (API.md / Swagger).
class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.category,
    required this.amount,
    required this.expenseDate,
    required this.description,
    required this.registeredByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id'] as String,
    storeId: json['storeId'] as String?,
    storeName: json['storeName'] as String?,
    category: ExpenseCategory.fromJson(json['category'] as String),
    amount: parseMoney(json['amount'] as String),
    expenseDate: parseLocalDate(json['expenseDate'] as String),
    description: json['description'] as String?,
    registeredByName: json['registeredByName'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
  );

  final String id;

  /// `null`: an expense of the whole business.
  final String? storeId;
  final String? storeName;
  final ExpenseCategory category;
  final double amount;
  final DateTime expenseDate;
  final String? description;
  final String? registeredByName;
  final DateTime createdAt;
  final DateTime updatedAt;
}
