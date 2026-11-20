import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/debt_kind.dart';
import 'package:subhon_app/models/debt_model.dart';
import 'package:subhon_app/models/money_category.dart';
import 'package:subhon_app/models/recurring_payment_model.dart';
import 'package:subhon_app/viewmodels/reminder_planner.dart';

void main() {
  final planner = ReminderPlanner(
    title: 'ИИ-бухгалтер',
    paymentTomorrow: (n, a) => 'Завтра $n $a',
    paymentToday: (n, a) => 'Сегодня $n $a',
    debtTomorrow: (n, a) => 'Долг завтра $n $a',
    debtToday: (n, a) => 'Долг сегодня $n $a',
    money: (v) => '${v.toStringAsFixed(0)} TJS',
  );

  test('the day before at 10:00 and on the day at 9:00; past times and '
      'closed debts are skipped', () {
    final plan = planner.plan(
      now: DateTime(2026, 11, 20, 12),
      recurring: [
        RecurringPaymentModel(
          id: 'r',
          name: 'Интернет',
          amount: 200,
          category: MoneyCategory.phone,
          nextDate: DateTime(2026, 11, 21),
        ),
      ],
      debts: [
        DebtModel(
          id: 'd',
          kind: DebtKind.iOwe,
          name: 'Фируз',
          amount: 1000,
          createdAt: DateTime(2026, 11),
          dueDate: DateTime(2026, 11, 25),
        ),
      ],
    );
    // 20 Nov 10:00 is already past; 21 Nov 9:00, 24 Nov 10:00, 25 Nov 9:00.
    expect(
      [for (final r in plan) r.body],
      [
        'Сегодня Интернет 200 TJS',
        'Долг завтра Фируз 1000 TJS',
        'Долг сегодня Фируз 1000 TJS',
      ],
    );
    expect(plan.first.when, DateTime(2026, 11, 21, 9));
    expect({for (final r in plan) r.id}.length, plan.length);
  });
}
