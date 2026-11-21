import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/money_account_kind.dart';
import 'package:subhon_app/models/money_account_model.dart';
import 'package:subhon_app/models/personal_finance_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/fake_file_pick_service.dart';
import '../helpers/fake_file_share_service.dart';
import '../helpers/memory_debt_storage.dart';
import '../helpers/memory_personal_finance_storage.dart';
import '../helpers/memory_token_storage.dart';

const _user = '11111111-1111-1111-1111-111111111111';

void main() {
  testWidgets('a backup file is saved, a wrong file is refused, and the '
      'backup brings the accounts back on an empty phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final personal = MemoryPersonalFinanceStorage()
      ..byUser[_user] = PersonalFinanceModel(
        accounts: [
          MoneyAccountModel(
            id: 'alif',
            name: 'Алиф',
            kind: MoneyAccountKind.card,
            openingBalance: 777,
            createdAt: DateTime(2026),
          ),
        ],
      );
    final files = FakeFileShareService();
    final pick = FakeFilePickService();
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
      personal: personal,
      debts: MemoryDebtStorage(),
      fileShare: files,
      filePick: pick,
    );
    await tapText(tester, 'Ещё');
    await tapText(tester, 'Резервная копия');
    await tapText(tester, 'Сохранить копию в файл');
    final (name, bytes) = files.shared.single;
    expect(name, endsWith('.json'));
    expect(utf8.decode(bytes), contains('Алиф'));

    pick.file = utf8.encode('{"hello": 1}');
    await tapText(tester, 'Восстановить из файла');
    expect(
      find.text('Этот файл — не резервная копия этого приложения.'),
      findsOneWidget,
    );

    // A new phone: nothing on it, then the backup.
    personal.byUser.clear();
    pick.file = bytes;
    await tapText(tester, 'Восстановить из файла');
    expect(find.textContaining('счетов 1, операций 0'), findsOneWidget);
    await tapText(tester, 'Восстановить');
    expect(personal.byUser[_user]!.accounts.single.name, 'Алиф');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tapText(tester, 'Главная');
    expect(find.text('Алиф'), findsOneWidget);
  });
}
