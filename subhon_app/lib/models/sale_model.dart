import '../core/utils/local_date.dart';
import '../core/utils/money.dart';
import 'payment_method.dart';

/// `SaleOut` from the API contract (API.md / Swagger).
class SaleModel {
  const SaleModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.amount,
    required this.saleDate,
    this.description,
    this.paymentMethod,
    this.cashAmount,
    this.cardAmount,
    this.receiptNumber,
    this.registeredByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
    id: json['id'] as String,
    storeId: json['storeId'] as String,
    storeName: json['storeName'] as String,
    amount: parseMoney(json['amount'] as String),
    saleDate: parseLocalDate(json['saleDate'] as String),
    description: json['description'] as String?,
    paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] as String?),
    cashAmount: json['cashAmount'] == null
        ? null
        : parseMoney(json['cashAmount'] as String),
    cardAmount: json['cardAmount'] == null
        ? null
        : parseMoney(json['cardAmount'] as String),
    receiptNumber: json['receiptNumber'] as String?,
    registeredByName: json['registeredByName'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
  );

  final String id;
  final String storeId;
  final String storeName;
  final double amount;
  final DateTime saleDate;
  final String? description;

  /// How it was paid; `null` when not recorded.
  final PaymentMethod? paymentMethod;

  /// Optional split; together they make [amount].
  final double? cashAmount;
  final double? cardAmount;
  final String? receiptNumber;

  /// Who recorded the sale (set by the server).
  final String? registeredByName;
  final DateTime createdAt;
  final DateTime updatedAt;
}
