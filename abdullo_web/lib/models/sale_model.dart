import '../core/utils/json.dart';

enum PaymentMethod {
  cash('Cash'),
  card('Card'),
  qr('QR');

  const PaymentMethod(this.label);
  final String label;

  static PaymentMethod parse(Object? v) =>
      PaymentMethod.values.firstWhere((m) => m.name == '$v'.toLowerCase(), orElse: () => PaymentMethod.cash);
}

/// GET /sales, POST /sales
class SaleModel {
  const SaleModel({
    required this.id,
    required this.receipt,
    required this.storeId,
    required this.storeName,
    required this.amount,
    required this.method,
    required this.register,
    required this.time,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
    id: asString(json['id']),
    receipt: asString(json['receipt']),
    storeId: asString(json['storeId']),
    storeName: asString(json['storeName']),
    amount: asDouble(json['amount']),
    method: PaymentMethod.parse(json['method']),
    register: asString(json['register']),
    time: asDate(json['time']),
  );

  final String id;
  final String receipt;
  final String storeId;
  final String storeName;
  final double amount;
  final PaymentMethod method;
  final String register;
  final DateTime time;

  Map<String, dynamic> toJson() => {
    'id': id,
    'receipt': receipt,
    'storeId': storeId,
    'storeName': storeName,
    'amount': amount,
    'method': method.name,
    'register': register,
    'time': time.toIso8601String(),
  };
}
