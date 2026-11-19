/// `ExpenseCategory` (API.md).
enum ExpenseCategory {
  rent('RENT'),
  utilities('UTILITIES'),
  delivery('DELIVERY'),
  supplies('SUPPLIES'),
  marketing('MARKETING'),
  taxes('TAXES'),
  other('OTHER');

  const ExpenseCategory(this.json);

  final String json;

  static ExpenseCategory fromJson(String value) =>
      values.firstWhere((v) => v.json == value, orElse: () => other);
}
