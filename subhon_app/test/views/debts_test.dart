import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/storage/secure_debt_storage.dart';
import 'package:subhon_app/models/debt_kind.dart';
import 'package:subhon_app/models/money_transaction_kind.dart';
import 'package:subhon_app/models/money_category.dart';
import 'package:subhon_app/viewmodels/debts_view_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_debt_storage.dart';
import '../helpers/memory_personal_finance_storage.dart';
import '../helpers/memory_token_storage.dart';

const _user = '11111111-1111-1111-1111-111111111111';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('totals, partial and full repayment, people counted once', () async {
    final storage = MemoryDebtStorage();
    final vm = DebtsViewModel(
      storage,
      _user,
      clock: () => DateTime(2026, 11, 19, 12),
    );
    await vm.load();
    final a = await vm.add(
      kind: DebtKind.owedToMe,
      name: 'Алишер',
      amount: 500,
    );
    await vm.add(kind: DebtKind.owedToMe, name: 'алишер ', amount: 300);
    await vm.add(kind: DebtKind.iOwe, name: 'Фируз', amount: 1000);
    await vm.add(
      kind: DebtKind.credit,
      name: 'Алиф Банк',
      amount: 12000,
      monthlyPayment: 1000,
    );
    expect(vm.owedToMeTotal, 800);
    expect(vm.owedToMePeople, 1);
    expect(vm.iOweTotal, 1000);
    expect(vm.loansTotal, 12000);

    await vm.repay(a.id, 200);
    expect(vm.byId(a.id)!.remaining, 300);
    // Never more than what is left.
    await vm.repay(a.id, 9999);
    expect(vm.byId(a.id)!.isClosed, isTrue);
    expect(vm.owedToMeTotal, 300);
    expect(vm.closed.single.id, a.id);
    // Saved for this account.
    expect(storage.byUser[_user], hasLength(4));
  });

  test('saved per account on the phone, survives bad data', () async {
    FlutterSecureStorage.setMockInitialValues({'ofar.debts.u2': 'oops'});
    const storage = SecureDebtStorage();
    final vm = DebtsViewModel(storage, 'u1');
    await vm.load();
    await vm.add(
      kind: DebtKind.iOwe,
      name: 'Фируз',
      amount: 100,
      dueDate: DateTime(2026, 12, 1),
    );
    final again = DebtsViewModel(storage, 'u1');
    await again.load();
    expect(again.iOwe.single.dueDate, DateTime(2026, 12, 1));
    expect(await storage.read('u2'), isEmpty);
  });

  testWidgets('the "Долги" tab: overview, add a debt, repay it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final storage = MemoryDebtStorage();
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      debts: storage,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Долги');
    expect(find.text('Долги и кредиты'), findsOneWidget);
    expect(find.text('Вам должны деньги'), findsOneWidget);
    expect(find.text('Нет активных кредитов и рассрочек'), findsOneWidget);

    await tapText(tester, 'Добавить долг');
    await tester.enterText(fieldWithLabel('Кто'), 'Алишер');
    await tester.enterText(fieldWithLabel('Сумма'), '500');
    await tapText(tester, 'Сохранить');
    expect(find.text('Алишер'), findsOneWidget);
    expect(find.text('1 чел.'), findsOneWidget);

    await tapText(tester, 'Алишер');
    await tapText(tester, 'Записать погашение');
    await tester.enterText(find.byType(EditableText).last, '200');
    await tapText(tester, 'Сохранить');
    expect(find.textContaining('Осталось 300'), findsOneWidget);
    expect(storage.byUser[_user]!.single.paid, 200);

    // "Я должен" has its own list.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tapText(tester, 'Я должен');
    expect(find.text('Вы должны деньги'), findsOneWidget);
  });

  testWidgets('"+" has "Продажи": the sales list opens as a page', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      debts: MemoryDebtStorage(),
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tester.tap(find.byTooltip('Добавить'));
    await tester.pumpAndSettle();
    await tapText(tester, 'Продажи');
    expect(find.widgetWithText(AppBar, 'Продажи'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('a debt written to an account: lending takes the money from '
      '"Наличные", a repayment brings it back', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final personal = MemoryPersonalFinanceStorage();
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      debts: MemoryDebtStorage(),
      personal: personal,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Долги');
    await tapText(tester, 'Добавить долг');
    expect(find.text('Записать в счёт'), findsOneWidget);
    await tester.enterText(fieldWithLabel('Кто'), 'Алишер');
    await tester.enterText(fieldWithLabel('Сумма'), '500');
    await tapText(tester, 'Сохранить');

    var data = personal.byUser.values.single;
    final lent = data.transactions.single;
    expect(lent.kind, MoneyTransactionKind.expense);
    expect(lent.category, MoneyCategory.debtOut);
    expect(lent.amount, 500);
    expect(lent.note, 'Алишер');

    await tapText(tester, 'Алишер');
    await tapText(tester, 'Записать погашение');
    await tester.enterText(find.byType(EditableText).first, '200');
    await tapText(tester, 'Сохранить');
    data = personal.byUser.values.single;
    final back = data.transactions.last;
    expect(back.kind, MoneyTransactionKind.income);
    expect(back.category, MoneyCategory.debtBack);
    expect(back.amount, 200);
  });
}
