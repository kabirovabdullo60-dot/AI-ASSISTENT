/// One line of a statement: when, who or where, a detail and the amount,
/// plus every column for the Excel file.
class StatementRowModel {
  const StatementRowModel({
    required this.title,
    required this.amount,
    required this.cells,
    this.date,
    this.detail,
  });

  final DateTime? date;
  final String title;

  /// Text, or a value turned into text by the screen (payment method,
  /// expense category, an activity…).
  final Object? detail;

  /// Signed: incoming +, outgoing −.
  final double amount;

  /// The Excel columns, in the order of the statement's headers
  /// (DateTime, String, num, enums…).
  final List<Object?> cells;
}
