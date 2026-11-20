import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/storage/secure_personal_finance_storage.dart';
import 'package:subhon_app/models/fiat_rates_model.dart';
import 'package:subhon_app/models/money_account_kind.dart';
import 'package:subhon_app/models/money_category.dart';
import 'package:subhon_app/models/money_transaction_kind.dart';
import 'package:subhon_app/viewmodels/personal_finance_view_model.dart';

import '../helpers/memory_personal_finance_storage.dart';

PersonalFinanceViewModel _vm() => PersonalFinanceViewModel(
  MemoryPersonalFinanceStorage(),
  'u1',
  clock: () => DateTime(2026, 11, 19, 12),
);

void main() {
  test('balances: opening + income − expenses, transfers move money', () async {
    final vm = _vm();
    await vm.load();
    await vm.ensureDefaultAccount('Наличные');
    final cash = vm.accounts.single;
    final card = await vm.addAccount(
      name: 'Алиф',
      kind: MoneyAccountKind.card,
      openingBalance: 1000,
    );
    await vm.addTransaction(
      kind: MoneyTransactionKind.income,
      amount: 5000,
      accountId: card.id,
      category: MoneyCategory.salary,
    );
    await vm.addTransaction(
      kind: MoneyTransactionKind.expense,
      amount: 300,
      accountId: cash.id,
      category: MoneyCategory.food,
    );
    await vm.addTransaction(
      kind: MoneyTransactionKind.transfer,
      amount: 2000,
      accountId: card.id,
      toAccountId: cash.id,
    );
    expect(vm.balance(card.id), 4000);
    expect(vm.balance(cash.id), 1700);
    expect(vm.totalBalance, 5700);
    // Transfers are not income or expenses.
    expect(vm.monthIncome, 5000);
    expect(vm.monthExpense, 300);
    expect(vm.monthExpensesByCategory.single, (MoneyCategory.food, 300.0));
    // An account with operations can't be deleted.
    expect(await vm.deleteAccount(card.id), isFalse);
  });

  test('months: only that month counts', () async {
    final vm = _vm();
    await vm.load();
    await vm.ensureDefaultAccount('Наличные');
    await vm.addTransaction(
      kind: MoneyTransactionKind.expense,
      amount: 100,
      accountId: vm.accounts.single.id,
      date: DateTime(2026, 10, 30),
      category: MoneyCategory.cafe,
    );
    expect(vm.monthExpense, 0);
    vm.shiftMonth(-1);
    expect(vm.monthExpense, 100);
    expect(vm.isCurrentMonth, isFalse);
  });

  test('a regular payment: due soon, paid → an expense, next month', () async {
    final vm = _vm();
    await vm.load();
    await vm.ensureDefaultAccount('Наличные');
    await vm.saveRecurring(
      name: 'Интернет',
      amount: 150,
      category: MoneyCategory.phone,
      nextDate: DateTime(2026, 11, 21),
    );
    await vm.saveRecurring(
      name: 'Аренда',
      amount: 2000,
      category: MoneyCategory.home,
      nextDate: DateTime(2026, 12, 31),
    );
    expect(vm.upcoming().map((r) => r.name), ['Интернет']);
    await vm.payRecurring(vm.upcoming().single.id);
    expect(vm.monthExpense, 150);
    expect(vm.recurring.first.nextDate, DateTime(2026, 12, 21));
    expect(vm.upcoming(), isEmpty);
  });

  test('the 31st moves to the end of a shorter month', () async {
    final vm = _vm();
    await vm.load();
    await vm.saveRecurring(
      name: 'Аренда',
      amount: 1,
      category: MoneyCategory.home,
      nextDate: DateTime(2027, 1, 31),
    );
    expect(vm.recurring.single.followingDate, DateTime(2027, 2, 28));
  });

  test('saved per account in the secure storage', () async {
    FlutterSecureStorage.setMockInitialValues({'ofar.personal.u2': 'bad'});
    const storage = SecurePersonalFinanceStorage();
    final vm = PersonalFinanceViewModel(storage, 'u1');
    await vm.load();
    await vm.ensureDefaultAccount('Наличные');
    final again = PersonalFinanceViewModel(storage, 'u1');
    await again.load();
    expect(again.accounts.single.name, 'Наличные');
    expect((await storage.read('u2')).accounts, isEmpty);
  });

  test(
    'summary for the AI: balances, month, categories, due payments',
    () async {
      final vm = PersonalFinanceViewModel(
        MemoryPersonalFinanceStorage(),
        'u1',
        clock: () => DateTime(2026, 11, 19, 12),
      );
      await vm.load();
      expect(vm.summary(), isNull);
      final card = await vm.addAccount(
        name: 'Алиф',
        kind: MoneyAccountKind.card,
        openingBalance: 1000,
      );
      await vm.addTransaction(
        kind: MoneyTransactionKind.expense,
        amount: 150,
        accountId: card.id,
        category: MoneyCategory.food,
      );
      await vm.saveRecurring(
        name: 'Интернет',
        amount: 200,
        category: MoneyCategory.phone,
        nextDate: DateTime(2026, 11, 25),
      );
      final note = vm.summary()!;
      expect(note, contains('Total balance: 850.00'));
      expect(note, contains('Алиф 850.00'));
      expect(note, contains('expenses 150.00'));
      expect(note, contains('food 150.00'));
      expect(note, contains('Интернет 200.00 on 2026-11-25'));
    },
  );

  test('accounts in other currencies: balances in their currency, totals '
      'in somoni at the rate, transfers between currencies', () async {
    final vm = PersonalFinanceViewModel(
      MemoryPersonalFinanceStorage(),
      'u1',
      clock: () => DateTime(2026, 11, 20, 12),
    );
    await vm.load();
    final cash = await vm.addAccount(
      name: 'Наличные',
      kind: MoneyAccountKind.cash,
      openingBalance: 1000,
    );
    final usd = await vm.addAccount(
      name: 'Доллары',
      kind: MoneyAccountKind.cash,
      openingBalance: 100,
      currency: 'USD',
    );
    expect(vm.ratesMissing, isTrue);
    vm.setRates(
      FiatRatesModel(
        perUsd: const {'USD': 1, 'TJS': 10, 'RUB': 80},
        updatedAt: DateTime(2026, 11, 20),
      ),
    );
    expect(vm.ratesMissing, isFalse);
    expect(vm.totalBalance, 2000); // 1000 + 100 × 10

    // 50 USD sold for 520 TJS.
    await vm.addTransaction(
      kind: MoneyTransactionKind.transfer,
      amount: 50,
      accountId: usd.id,
      toAccountId: cash.id,
      toAmount: 520,
    );
    expect(vm.balance(usd.id), 50);
    expect(vm.balance(cash.id), 1520);
    expect(vm.totalBalance, 2020);

    await vm.addTransaction(
      kind: MoneyTransactionKind.expense,
      amount: 5,
      accountId: usd.id,
      category: MoneyCategory.cafe,
    );
    expect(vm.monthExpense, 50); // 5 USD in somoni
    expect(vm.summary(), contains('Доллары 45.00 USD'));

    // The currency stays once the account has operations.
    await vm.updateAccount(
      usd.id,
      name: 'Доллары',
      kind: MoneyAccountKind.cash,
      openingBalance: 100,
      currency: 'RUB',
    );
    expect(vm.account(usd.id)!.currency, 'USD');
  });
}
