import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/utils/quick_entry_parser.dart';
import 'package:subhon_app/models/money_account_kind.dart';
import 'package:subhon_app/models/money_account_model.dart';
import 'package:subhon_app/models/money_category.dart';
import 'package:subhon_app/models/money_transaction_kind.dart';

final _accounts = [
  MoneyAccountModel(
    id: 'cash',
    name: 'Наличные',
    kind: MoneyAccountKind.cash,
    openingBalance: 0,
    createdAt: DateTime(2026),
  ),
  MoneyAccountModel(
    id: 'alif',
    name: 'Алиф',
    kind: MoneyAccountKind.card,
    openingBalance: 0,
    createdAt: DateTime(2026),
  ),
  MoneyAccountModel(
    id: 'save',
    name: 'Копилка',
    kind: MoneyAccountKind.savings,
    openingBalance: 0,
    createdAt: DateTime(2026),
  ),
];

void main() {
  test('an expense: amount, category, no account', () {
    final e = QuickEntryParser.parse('такси 50', _accounts)!;
    expect(e.kind, MoneyTransactionKind.expense);
    expect(e.amount, 50);
    expect(e.category, MoneyCategory.transport);
    expect(e.accountId, isNull);
    expect(e.note, 'Такси');
    expect(e.isComplete, isTrue);
  });

  test('card words, decimals, thousands and spaces in numbers', () {
    final a = QuickEntryParser.parse('Обед 35,50 сомони картой', _accounts)!;
    expect(a.amount, 35.5);
    expect(a.category, MoneyCategory.cafe);
    expect(a.accountId, 'alif');
    expect(a.note, 'Обед картой');

    expect(QuickEntryParser.parse('аренда 1 500', _accounts)!.amount, 1500);
    expect(QuickEntryParser.parse('интернет 1,5к', _accounts)!.amount, 1500);
    expect(QuickEntryParser.parse('ремонт 2 тыс', _accounts)!.amount, 2000);
  });

  test('income by its words; the account by its own name', () {
    final e = QuickEntryParser.parse(
      'получил зарплату 3000 на Алиф',
      _accounts,
    )!;
    expect(e.kind, MoneyTransactionKind.income);
    expect(e.category, MoneyCategory.salary);
    expect(e.amount, 3000);
    expect(e.accountId, 'alif');

    final other = QuickEntryParser.parse('пришли деньги 200', _accounts)!;
    expect(other.category, MoneyCategory.otherIncome);
  });

  test('Tajik and English phrases; unknown words leave the category', () {
    expect(QuickEntryParser.parse('нон 10 нақд', _accounts)!.accountId, 'cash');
    expect(
      QuickEntryParser.parse('нон 10', _accounts)!.category,
      MoneyCategory.food,
    );
    expect(
      QuickEntryParser.parse('maosh 1000 salary', _accounts)!.kind,
      MoneyTransactionKind.income,
    );
    final unknown = QuickEntryParser.parse('что-то 70', _accounts)!;
    expect(unknown.category, isNull);
    expect(unknown.isComplete, isFalse);
    expect(QuickEntryParser.parse('такси', _accounts)!.amount, isNull);
    expect(QuickEntryParser.parse('  ', _accounts), isNull);
  });
}
