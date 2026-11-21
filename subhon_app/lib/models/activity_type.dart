/// `ActivityType` (API.md): what was changed.
enum ActivityType {
  store('STORE'),
  sale('SALE'),
  employee('EMPLOYEE'),
  payroll('PAYROLL'),
  profile('PROFILE'),
  unknown('');

  const ActivityType(this.json);

  final String json;

  static ActivityType fromJson(String value) =>
      values.firstWhere((v) => v.json == value, orElse: () => unknown);
}
