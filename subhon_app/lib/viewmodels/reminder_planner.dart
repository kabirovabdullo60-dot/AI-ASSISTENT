import '../models/debt_model.dart';
import '../models/recurring_payment_model.dart';
import '../models/reminder_model.dart';

/// Plans the phone's reminders: for each regular payment the day before
/// (at 10:00) and on the day (at 9:00); for each open debt with a due date
/// the day before and on the day. At most [limit] (iOS keeps 64).
class ReminderPlanner {
  const ReminderPlanner({
    required this.title,
    required this.paymentTomorrow,
    required this.paymentToday,
    required this.debtTomorrow,
    required this.debtToday,
    required this.money,
    this.limit = 60,
  });

  final String title;
  final String Function(String name, String amount) paymentTomorrow;
  final String Function(String name, String amount) paymentToday;
  final String Function(String name, String amount) debtTomorrow;
  final String Function(String name, String amount) debtToday;
  final String Function(double amount) money;
  final int limit;

  List<ReminderModel> plan({
    required List<RecurringPaymentModel> recurring,
    required List<DebtModel> debts,
    required DateTime now,
  }) {
    final items = <ReminderModel>[];
    var id = 1;
    void add(DateTime day, int hour, String body) {
      final when = DateTime(day.year, day.month, day.day, hour);
      if (when.isAfter(now)) {
        items.add(
          ReminderModel(id: id++, title: title, body: body, when: when),
        );
      }
    }

    for (final r in recurring) {
      final amount = money(r.amount);
      add(
        r.nextDate.subtract(const Duration(days: 1)),
        10,
        paymentTomorrow(r.name, amount),
      );
      add(r.nextDate, 9, paymentToday(r.name, amount));
    }
    for (final d in debts) {
      final due = d.dueDate;
      if (due == null || d.isClosed) continue;
      final amount = money(d.remaining);
      add(
        due.subtract(const Duration(days: 1)),
        10,
        debtTomorrow(d.name, amount),
      );
      add(due, 9, debtToday(d.name, amount));
    }
    items.sort((a, b) => a.when.compareTo(b.when));
    return items.take(limit).toList();
  }
}
