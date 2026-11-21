import '../core/utils/local_date.dart';
import 'statement_kind.dart';

/// A statement that was opened, kept in "Мои выписки" to open it again.
class StatementRequestModel {
  const StatementRequestModel({
    required this.kind,
    required this.openedAt,
    this.startDate,
    this.endDate,
    this.storeId,
    this.storeName,
  });

  /// `null` when saved by a newer version with an unknown kind.
  static StatementRequestModel? fromJson(Map<String, dynamic> json) {
    final kind = StatementKind.fromName(json['kind'] as String);
    if (kind == null) return null;
    DateTime? date(String key) =>
        json[key] == null ? null : parseLocalDate(json[key] as String);
    return StatementRequestModel(
      kind: kind,
      startDate: date('startDate'),
      endDate: date('endDate'),
      storeId: json['storeId'] as String?,
      storeName: json['storeName'] as String?,
      openedAt: DateTime.parse(json['openedAt'] as String).toLocal(),
    );
  }

  final StatementKind kind;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? storeId;
  final String? storeName;
  final DateTime openedAt;

  /// The same statement (kind, period, store).
  bool sameAs(StatementRequestModel other) =>
      kind == other.kind &&
      startDate == other.startDate &&
      endDate == other.endDate &&
      storeId == other.storeId;

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    if (startDate != null) 'startDate': formatLocalDate(startDate!),
    if (endDate != null) 'endDate': formatLocalDate(endDate!),
    'storeId': ?storeId,
    'storeName': ?storeName,
    'openedAt': openedAt.toUtc().toIso8601String(),
  };
}
