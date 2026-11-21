/// `PaymentMethod` (API.md): how a sale was paid.
enum PaymentMethod {
  cash('CASH'),
  card('CARD'),
  qr('QR'),
  mixed('MIXED');

  const PaymentMethod(this.json);

  final String json;

  /// `null` for an unknown or missing value.
  static PaymentMethod? fromJson(String? value) =>
      values.where((v) => v.json == value).firstOrNull;
}
