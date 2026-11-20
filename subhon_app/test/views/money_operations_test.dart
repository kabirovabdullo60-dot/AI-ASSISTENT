import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/money_account_kind.dart';
import 'package:subhon_app/models/money_account_model.dart';
import 'package:subhon_app/models/money_category.dart';
import 'package:subhon_app/models/money_transaction_kind.dart';
import 'package:subhon_app/models/money_transaction_model.dart';
import 'package:subhon_app/models/personal_finance_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/fake_file_share_service.dart';
import '../helpers/memory_personal_finance_storage.dart';
import '../helpers/memory_token_storage.dart';

const _user = '11111111-1111-1111-1111-111111111111';

MoneyTransactionModel _t(
  String id,
  MoneyTransactionKind kind,
  double amount,
  MoneyCategory category,
  String note,
) => MoneyTransactionModel(
  id: id,
  kind: kind,
  amount: amount,
  date: DateTime(2026, 11, 18),
  accountId: 'cash',
  createdAt: DateTime(2026, 11, 18),
  category: category,
  note: note,
);

void main() {
  testWidgets('"Операции": search by note or category, filter by type, '
      'the found totals, and "В Excel" with every found row', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final personal = MemoryPersonalFinanceStorage()
      ..byUser[_user] = PersonalFinanceModel(
        accounts: [
          MoneyAccountModel(
            id: 'cash',
            name: 'Наличные',
            kind: MoneyAccountKind.cash,
            openingBalance: 0,
            createdAt: DateTime(2026),
          ),
        ],
        transactions: [
          _t(
            '1',
            MoneyTransactionKind.expense,
            50,
            MoneyCategory.transport,
            'Такси домой',
          ),
          _t('2', MoneyTransactionKind.expense, 35, MoneyCategory.cafe, 'Обед'),
          _t(
            '3',
            MoneyTransactionKind.income,
            3000,
            MoneyCategory.salary,
            'Аванс',
          ),
        ],
      );
    final files = FakeFileShareService();
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
      personal: personal,
      fileShare: files,
    );
    await tapText(tester, 'Операции');
    expect(find.textContaining('Обед'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'такси');
    await tester.pumpAndSettle();
    expect(find.textContaining('Такси домой'), findsOneWidget);
    expect(find.textContaining('Обед'), findsNothing);

    // A category's name on screen is searched too.
    await tester.enterText(find.byType(TextField), 'кафе');
    await tester.pumpAndSettle();
    expect(find.textContaining('Обед'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await tapText(tester, 'Расходы');
    expect(find.textContaining('Аванс'), findsNothing);
    expect(find.textContaining('Найдено: 2'), findsOneWidget);
    expect(find.textContaining('расходы 85 TJS'), findsOneWidget);

    await tester.tap(find.byTooltip('В Excel'));
    await tester.pumpAndSettle();
    final (name, bytes) = files.shared.single;
    expect(name, endsWith('.xlsx'));
    final sheet = Excel.decodeBytes(bytes).tables.values.first;
    final notes = [
      for (final r in sheet.rows) r.length > 7 ? r[7]?.value.toString() : null,
    ];
    expect(notes, containsAll(['Такси домой', 'Обед']));
    expect(notes, isNot(contains('Аванс')));
  });
}
