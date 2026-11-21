/// A reminder shown by the phone at [when] (a regular payment or a debt
/// coming due).
class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.title,
    required this.body,
    required this.when,
  });

  final int id;
  final String title;
  final String body;
  final DateTime when;
}
