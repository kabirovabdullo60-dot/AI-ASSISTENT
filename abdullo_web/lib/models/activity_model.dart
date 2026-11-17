enum ActivityType { sale, payroll }

/// A row of "Recent Business Activity", built from the latest sales and salary payments.
class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.time,
    this.detail = '',
  });

  final String id;
  final ActivityType type;

  /// Store name (sale) or employee name (payment).
  final String title;

  /// Signed TJS: + income, - salary paid.
  final double amount;
  final DateTime time;

  /// Description / note.
  final String detail;

  String get searchText => '$title $detail'.toLowerCase();
}
