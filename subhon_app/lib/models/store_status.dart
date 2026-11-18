/// `StoreStatus` (API.md).
enum StoreStatus {
  active('ACTIVE'),
  inactive('INACTIVE');

  const StoreStatus(this.json);

  final String json;

  static StoreStatus fromJson(String value) =>
      values.firstWhere((v) => v.json == value);
}
