import 'money_account_kind.dart';

/// A personal account or wallet (cash, a card…), kept on the phone.
class MoneyAccountModel {
  const MoneyAccountModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.openingBalance,
    required this.createdAt,
    this.currency = 'TJS',
  });

  /// The currencies an account can be kept in.
  static const currencies = ['TJS', 'USD', 'RUB', 'EUR'];

  factory MoneyAccountModel.fromJson(Map<String, dynamic> json) =>
      MoneyAccountModel(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: MoneyAccountKind.fromName(json['kind'] as String),
        openingBalance: (json['openingBalance'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        currency: json['currency'] as String? ?? 'TJS',
      );

  final String id;
  final String name;
  final MoneyAccountKind kind;

  /// What was on it when it was added.
  final double openingBalance;
  final DateTime createdAt;

  /// Its balance and operations are in this currency (`TJS`, `USD`…).
  final String currency;

  MoneyAccountModel copyWith({
    String? name,
    MoneyAccountKind? kind,
    double? openingBalance,
    String? currency,
  }) => MoneyAccountModel(
    id: id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    openingBalance: openingBalance ?? this.openingBalance,
    createdAt: createdAt,
    currency: currency ?? this.currency,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'openingBalance': openingBalance,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'currency': currency,
  };
}
