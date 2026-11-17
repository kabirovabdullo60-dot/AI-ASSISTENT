import '../core/utils/json.dart';

enum ActivityType { sale, payroll, audit, staff }

/// GET /activity — one row of "Recent Business Activity".
/// Shown as: [text] **[highlight]**[detail]: [amount]
class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.type,
    required this.text,
    required this.highlight,
    this.detail = '',
    this.amount,
    this.reference = '',
    this.tag = '',
    required this.time,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
    id: asString(json['id']),
    type: ActivityType.values.asNameMap()[json['type']] ?? ActivityType.audit,
    text: asString(json['text']),
    highlight: asString(json['highlight']),
    detail: asString(json['detail']),
    amount: json['amount'] == null ? null : asDouble(json['amount']),
    reference: asString(json['reference']),
    tag: asString(json['tag']),
    time: asDate(json['time']),
  );

  final String id;
  final ActivityType type;
  final String text;
  final String highlight;
  final String detail;

  /// Signed TJS amount: + income, - payment. `null` = no amount.
  final double? amount;
  final String reference;
  final String tag;
  final DateTime time;

  String get searchText => '$text $highlight $detail $reference $tag'.toLowerCase();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'text': text,
    'highlight': highlight,
    'detail': detail,
    'amount': amount,
    'reference': reference,
    'tag': tag,
    'time': time.toIso8601String(),
  };
}
