import '../core/utils/json.dart';

/// `RENT`, `UTILITIES`, `DELIVERY`, `SUPPLIES`, `MARKETING`, `TAXES`, `OTHER`.
enum ExpenseCategory {
  rent,
  utilities,
  delivery,
  supplies,
  marketing,
  taxes,
  other;

  String get api => name.toUpperCase();

  static ExpenseCategory fromApi(Object? v) =>
      values.firstWhere((c) => c.api == '$v', orElse: () => ExpenseCategory.other);
}

/// `ExpenseOut` — a cost of one store, or of the whole business when [storeId] is null.
class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.storeId,
    this.storeName,
    this.description,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: asString(json['id']),
    storeId: json['storeId'] as String?,
    storeName: json['storeName'] as String?,
    category: ExpenseCategory.fromApi(json['category']),
    amount: asDouble(json['amount']),
    expenseDate: asDay(json['expenseDate']),
    description: json['description'] as String?,
  );

  final String id;
  final String? storeId;
  final String? storeName;
  final ExpenseCategory category;
  final double amount;
  final DateTime expenseDate;
  final String? description;

  /// Body of POST /api/expenses and PUT /api/expenses/{id} (`storeId: null` = whole business).
  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'category': category.api,
    'amount': money(amount),
    'expenseDate': isoDay(expenseDate),
    'description': (description ?? '').trim().isEmpty ? null : description!.trim(),
  };

  String get searchText => '${storeName ?? ''} ${description ?? ''} ${category.name}'.toLowerCase();
}
