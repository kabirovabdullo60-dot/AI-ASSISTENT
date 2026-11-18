/// `UserRole` (API.md).
enum UserRole {
  owner('OWNER');

  const UserRole(this.json);

  final String json;

  static UserRole fromJson(String value) =>
      values.firstWhere((v) => v.json == value);
}
