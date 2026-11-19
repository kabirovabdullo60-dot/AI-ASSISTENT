/// `NotificationLink` (API.md): the app screen a notification opens.
enum NotificationLink {
  stores('STORES'),
  sales('SALES'),
  payroll('PAYROLL'),
  unknown('');

  const NotificationLink(this.json);

  final String json;

  static NotificationLink fromJson(String value) =>
      values.firstWhere((v) => v.json == value, orElse: () => unknown);
}
