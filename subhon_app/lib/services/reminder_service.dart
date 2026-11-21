import '../models/reminder_model.dart';

/// The phone's own notifications for reminders. Abstract so tests can use
/// a fake.
abstract class ReminderService {
  /// Replaces every planned reminder with [reminders] (asks for permission
  /// the first time there is something to remind).
  Future<void> replaceAll(List<ReminderModel> reminders);
}
