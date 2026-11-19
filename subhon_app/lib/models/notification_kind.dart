/// `NotificationKind` (API.md).
enum NotificationKind {
  unpaidSalaries('UNPAID_SALARIES'),
  storeNoSalesToday('STORE_NO_SALES_TODAY'),
  salaryOverdue('SALARY_OVERDUE'),
  unknown('');

  const NotificationKind(this.json);

  final String json;

  static NotificationKind fromJson(String value) =>
      values.firstWhere((v) => v.json == value, orElse: () => unknown);
}
