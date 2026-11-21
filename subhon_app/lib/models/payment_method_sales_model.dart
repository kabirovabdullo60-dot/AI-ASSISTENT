import '../core/utils/money.dart';
import 'payment_method.dart';

/// `PaymentMethodSalesOut` from the API contract (API.md / Swagger).
class PaymentMethodSalesModel {
  const PaymentMethodSalesModel({
    required this.paymentMethod,
    required this.totalAmount,
    required this.salesCount,
    required this.sharePercent,
  });

  factory PaymentMethodSalesModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodSalesModel(
        paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] as String?),
        totalAmount: parseMoney(json['totalAmount'] as String),
        salesCount: json['salesCount'] as int,
        sharePercent: (json['sharePercent'] as num).toDouble(),
      );

  /// `null`: sales recorded without a payment method.
  final PaymentMethod? paymentMethod;
  final double totalAmount;
  final int salesCount;
  final double sharePercent;
}
