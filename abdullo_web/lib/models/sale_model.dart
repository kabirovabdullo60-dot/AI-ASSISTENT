import '../core/utils/json.dart';

/// "Primary Balance Split" of a daily entry.
enum BalanceSplit {
  balanced('Balanced'),
  posHeavy('POS > 80%'),
  cashHeavy('Cash Heavy');

  const BalanceSplit(this.label);
  final String label;

  static BalanceSplit parse(Object? v) =>
      BalanceSplit.values.firstWhere((s) => s.name == '$v', orElse: () => BalanceSplit.balanced);
}

/// GET /sales, POST /sales — one daily sales entry of a store.
class SaleModel {
  const SaleModel({
    required this.id,
    required this.reference,
    required this.storeId,
    required this.storeName,
    required this.amount,
    required this.date,
    required this.registeredBy,
    this.split = BalanceSplit.balanced,
    this.notes = '',
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
    id: asString(json['id']),
    reference: asString(json['reference']),
    storeId: asString(json['storeId']),
    storeName: asString(json['storeName']),
    amount: asDouble(json['amount']),
    date: asDate(json['date']),
    registeredBy: asString(json['registeredBy']),
    split: BalanceSplit.parse(json['split']),
    notes: asString(json['notes']),
  );

  final String id;

  /// Receipt / entry number, e.g. "ENT-10421".
  final String reference;
  final String storeId;
  final String storeName;
  final double amount;
  final DateTime date;
  final String registeredBy;
  final BalanceSplit split;
  final String notes;

  String get searchText => '$reference $storeName $registeredBy $notes ${split.label}'.toLowerCase();

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'storeId': storeId,
    'storeName': storeName,
    'amount': amount,
    'date': date.toIso8601String(),
    'registeredBy': registeredBy,
    'split': split.name,
    'notes': notes,
  };
}
