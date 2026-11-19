import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/expense_category.dart';
import 'package:subhon_app/services/reports_service.dart';
import 'package:subhon_app/viewmodels/reports_view_model.dart';
import 'package:subhon_app/core/network/api_client.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

FakeBackend _backend() {
  final backend = FakeBackend()
    ..json('GET', '/api/auth/me', ApiJson.profile())
    ..json('GET', '/api/reports/profit', ApiJson.profit())
    ..json('GET', '/api/reports/payroll', ApiJson.payrollYear())
    ..json('GET', '/api/reports/employees', ApiJson.employeesReport());
  stubHome(backend);
  return backend;
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('reports show the profit, its parts, categories and stores', (
    tester,
  ) async {
    await pumpApp(
      tester,
      _backend(),
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Ещё');
    await tapText(tester, 'Отчёты');
    expect(find.text('Прибыль'), findsWidgets);
    expect(find.textContaining('82 028'), findsOneWidget);
    expect(find.textContaining('Маржа'), findsOneWidget);
    expect(find.text('Зарплаты начислено'), findsOneWidget);
    expect(find.text('Аренда'), findsOneWidget);
    expect(find.text('Коммунальные услуги'), findsOneWidget);
    expect(find.text('Весь бизнес'), findsOneWidget);
  });

  test(
    'the profit month: the current one up to today, then whole months',
    () async {
      final backend = _backend();
      final vm = ReportsViewModel(
        ReportsService(
          ApiClient(
            tokens: MemoryTokenStorage(accessToken: 'a'),
            client: backend.client,
          ),
        ),
        now: DateTime(2026, 11, 18),
      );
      await vm.load();
      var query = backend
          .calls('GET', '/api/reports/profit')
          .last
          .url
          .queryParameters;
      expect(query['startDate'], '2026-11-01');
      expect(query['endDate'], '2026-11-18');
      expect(vm.canShowNextProfitMonth, isFalse);
      expect(vm.profit!.byCategory.first.category, ExpenseCategory.rent);

      await vm.shiftProfitMonth(-1);
      query = backend
          .calls('GET', '/api/reports/profit')
          .last
          .url
          .queryParameters;
      expect(query['startDate'], '2026-10-01');
      expect(query['endDate'], '2026-10-31');
      expect(vm.canShowNextProfitMonth, isTrue);
    },
  );
}
