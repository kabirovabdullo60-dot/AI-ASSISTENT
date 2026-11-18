/// `PayrollStatus` (API.md).
enum PayrollStatus {
  paid('PAID'),
  partial('PARTIAL'),
  unpaid('UNPAID');

  const PayrollStatus(this.json);

  final String json;

  static PayrollStatus fromJson(String value) =>
      values.firstWhere((v) => v.json == value);
}
