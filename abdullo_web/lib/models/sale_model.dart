import '../core/utils/json.dart';

/// SaleOut — one sales record of a store for a day.
class SaleModel {
  const SaleModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.amount,
    required this.saleDate,
    this.description,
    this.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
    id: asString(json['id']),
    storeId: asString(json['storeId']),
    storeName: asString(json['storeName']),
    amount: asDouble(json['amount']),
    saleDate: asDay(json['saleDate']),
    description: json['description'] == null ? null : asString(json['description']),
    createdAt: json['createdAt'] == null ? null : asDate(json['createdAt']),
  );

  final String id;
  final String storeId;
  final String storeName;
  final double amount;
  final DateTime saleDate;
  final String? description;
  final DateTime? createdAt;

  String get searchText => '$storeName ${description ?? ''} $id'.toLowerCase();
}
