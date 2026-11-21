import 'statement_kind.dart';
import 'statement_row_model.dart';
import 'statement_total_kind.dart';

/// A ready statement or certificate: what, for which period (and store),
/// its lines and totals.
class StatementModel {
  const StatementModel({
    required this.kind,
    required this.rows,
    required this.totals,
    this.startDate,
    this.endDate,
    this.storeName,
    this.truncated = false,
  });

  final StatementKind kind;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? storeName;
  final List<StatementRowModel> rows;
  final List<(StatementTotalKind, double)> totals;

  /// Very long periods are cut to the newest lines (see the service).
  final bool truncated;
}
