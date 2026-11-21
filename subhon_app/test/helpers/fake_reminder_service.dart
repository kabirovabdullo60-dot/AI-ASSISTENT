import 'package:subhon_app/models/reminder_model.dart';
import 'package:subhon_app/services/reminder_service.dart';

/// Keeps the reminders the app planned.
class FakeReminderService implements ReminderService {
  List<ReminderModel> planned = [];
  int calls = 0;

  @override
  Future<void> replaceAll(List<ReminderModel> reminders) async {
    calls++;
    planned = reminders;
  }
}
