import '../core/utils/local_date.dart';
import 'payment_method.dart';

/// `SaleCreate` from the API contract (API.md / Swagger).
class SaleCreateModel {
  const SaleCreateModel({
    required this.storeId,
    required this.amount,
    this.saleDate,
    this.description,
    this.paymentMethod,
    this.cashAmount,
    this.cardAmount,
    this.receiptNumber,
  });

  final String storeId;
  final double amount;
  final DateTime? saleDate;
  final String? description;
  final PaymentMethod? paymentMethod;

  /// Optional split: both together must equal [amount]
  /// (`422 SALE_SPLIT_MISMATCH`).
  final double? cashAmount;
  final double? cardAmount;
  final String? receiptNumber;

  Map<String, dynamic> toJson() => {
    'storeId': storeId,
    'amount': amount.toStringAsFixed(2),
    if (saleDate != null) 'saleDate': formatLocalDate(saleDate!),
    'description': ?description,
    if (paymentMethod != null) 'paymentMethod': paymentMethod!.json,
    if (cashAmount != null) 'cashAmount': cashAmount!.toStringAsFixed(2),
    if (cardAmount != null) 'cardAmount': cardAmount!.toStringAsFixed(2),
    'receiptNumber': ?receiptNumber,
  };
}
