/// `SalaryPaymentMethod` (API.md): how a salary was paid.
enum SalaryPaymentMethod {
  bankTransfer('BANK_TRANSFER'),
  cash('CASH');

  const SalaryPaymentMethod(this.json);

  final String json;

  /// `null` for an unknown or missing value.
  static SalaryPaymentMethod? fromJson(String? value) =>
      values.where((v) => v.json == value).firstOrNull;
}
