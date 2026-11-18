/// `EmployeeStatus` (API.md).
enum EmployeeStatus {
  active('ACTIVE'),
  inactive('INACTIVE');

  const EmployeeStatus(this.json);

  final String json;

  static EmployeeStatus fromJson(String value) =>
      values.firstWhere((v) => v.json == value);
}
