import '../core/utils/local_date.dart';
import 'payment_method.dart';

/// `SaleUpdate` from the API contract (API.md / Swagger).
class SaleUpdateModel {
  const SaleUpdateModel({
    this.storeId,
    this.amount,
    this.saleDate,
    this.description,
    this.paymentMethod,
    this.cashAmount,
    this.cardAmount,
    this.receiptNumber,
  });

  final String? storeId;
  final double? amount;
  final DateTime? saleDate;
  final String? description;
  final PaymentMethod? paymentMethod;
  final double? cashAmount;
  final double? cardAmount;
  final String? receiptNumber;

  /// Fields sent as `null` to clear them (optional fields only).
  static const clearable = {
    'saleDate',
    'description',
    'paymentMethod',
    'cashAmount',
    'cardAmount',
    'receiptNumber',
  };

  /// PUT updates only the fields that are sent: a field left `null`
  /// is not sent, unless it is listed in [clear] (then it is cleared).
  Map<String, dynamic> toJson({Set<String> clear = const {}}) => {
    'storeId': ?storeId,
    if (amount != null) 'amount': amount!.toStringAsFixed(2),
    if (saleDate != null || clear.contains('saleDate'))
      'saleDate': saleDate == null ? null : formatLocalDate(saleDate!),
    if (description != null || clear.contains('description'))
      'description': description,
    if (paymentMethod != null || clear.contains('paymentMethod'))
      'paymentMethod': paymentMethod?.json,
    if (cashAmount != null || clear.contains('cashAmount'))
      'cashAmount': cashAmount?.toStringAsFixed(2),
    if (cardAmount != null || clear.contains('cardAmount'))
      'cardAmount': cardAmount?.toStringAsFixed(2),
    if (receiptNumber != null || clear.contains('receiptNumber'))
      'receiptNumber': receiptNumber,
  };
}
