import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/network/api_client.dart';
import 'package:subhon_app/models/employee_create_model.dart';
import 'package:subhon_app/models/login_request_model.dart';
import 'package:subhon_app/models/payment_create_model.dart';
import 'package:subhon_app/models/sale_create_model.dart';
import 'package:subhon_app/models/store_create_model.dart';
import 'package:subhon_app/models/store_update_model.dart';
import 'package:subhon_app/services/auth_service.dart';
import 'package:subhon_app/services/employee_service.dart';
import 'package:subhon_app/services/payroll_service.dart';
import 'package:subhon_app/services/profile_service.dart';
import 'package:subhon_app/services/reports_service.dart';
import 'package:subhon_app/services/sales_service.dart';
import 'package:subhon_app/services/store_service.dart';
import 'package:subhon_app/viewmodels/session_view_model.dart';

import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

Map<String, dynamic> _body(FakeBackend b, String method, String path) =>
    jsonDecode(b.calls(method, path).single.body) as Map<String, dynamic>;

void main() {
  late FakeBackend backend;
  late MemoryTokenStorage tokens;
  late ApiClient api;

  setUp(() {
    backend = FakeBackend();
    tokens = MemoryTokenStorage();
    api = ApiClient(tokens: tokens, client: backend.client);
  });

  group('auth', () {
    test('login: the user is returned and BOTH tokens are saved', () async {
      backend.json('POST', '/api/auth/login', ApiJson.auth());
      final user = await AuthService(api, tokens).login(
        const LoginRequestModel(email: 'farhod@bahor.tj', password: 'secret'),
      );
      expect(user.fullName, 'Фарход Назаров');
      expect(user.business.name, 'Магазин «Бахор»');
      expect(tokens.accessToken, 'access-1');
      expect(tokens.refreshToken, 'refresh-1');
      expect(_body(backend, 'POST', '/api/auth/login'), {
        'email': 'farhod@bahor.tj',
        'password': 'secret',
      });
      expect(
        backend.requests.single.headers['Authorization'],
        isNull,
        reason: 'login is not a protected call',
      );
    });

    test('wrong password: AUTH_INVALID_CREDENTIALS, nothing saved', () async {
      backend.on(
        'POST',
        '/api/auth/login',
        (_) => FakeBackend.error(401, 'AUTH_INVALID_CREDENTIALS', 'Wrong.'),
      );
      await expectLater(
        AuthService(
          api,
          tokens,
        ).login(const LoginRequestModel(email: 'a@b.tj', password: 'x')),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'AUTH_INVALID_CREDENTIALS',
          ),
        ),
      );
      expect(tokens.refreshToken, isNull);
    });

    test(
      'session restore: a saved session is checked with GET /api/auth/me',
      () async {
        tokens = MemoryTokenStorage(accessToken: 'a', refreshToken: 'r');
        api = ApiClient(tokens: tokens, client: backend.client);
        backend.json('GET', '/api/auth/me', ApiJson.profile());
        final session = SessionViewModel(AuthService(api, tokens), api);
        await session.restore();
        expect(session.status, SessionStatus.signedIn);
        expect(session.user?.email, 'farhod@bahor.tj');
        expect(backend.requests.single.headers['Authorization'], 'Bearer a');
      },
    );

    test('no saved session: signed out without calling the server', () async {
      final session = SessionViewModel(AuthService(api, tokens), api);
      await session.restore();
      expect(session.status, SessionStatus.signedOut);
      expect(backend.requests, isEmpty);
    });

    test(
      'logout ends the session on the server and clears the tokens',
      () async {
        tokens = MemoryTokenStorage(accessToken: 'a', refreshToken: 'r');
        api = ApiClient(tokens: tokens, client: backend.client);
        backend.json('POST', '/api/auth/logout', null, status: 204);
        await AuthService(api, tokens).logout();
        expect(_body(backend, 'POST', '/api/auth/logout'), {
          'refreshToken': 'r',
        });
        expect(tokens.accessToken, isNull);
        expect(tokens.refreshToken, isNull);
      },
    );
  });

  test('stores: create, update (cleared fields), delete', () async {
    final stores = StoreService(api);
    backend.json('POST', '/api/stores', ApiJson.store(), status: 201);
    final created = await stores.create(
      const StoreCreateModel(name: 'Бахор — Сомони', phone: '+992901234567'),
    );
    expect(created.name, 'Бахор — Сомони');
    expect(_body(backend, 'POST', '/api/stores'), {
      'name': 'Бахор — Сомони',
      'phone': '+992901234567',
      'status': 'ACTIVE',
    });
    final path = '/api/stores/${created.id}';
    backend.json('PUT', path, ApiJson.store(name: 'Бахор 2'));
    await stores.update(
      created.id,
      const StoreUpdateModel(name: 'Бахор 2'),
      clear: StoreUpdateModel.clearable,
    );
    expect(_body(backend, 'PUT', path), {
      'name': 'Бахор 2',
      'address': null,
      'phone': null,
      'description': null,
      'city': null,
      'region': null,
      'type': null,
      'counters': null,
      'openingHours': null,
      'statusNote': null,
    });
    backend.json('DELETE', path, null, status: 204);
    await stores.delete(created.id);
    expect(backend.calls('DELETE', path), hasLength(1));
  });

  test('store delete refused: STORE_HAS_ACTIVE_EMPLOYEES', () async {
    backend.on(
      'DELETE',
      '/api/stores/s1',
      (_) => FakeBackend.error(409, 'STORE_HAS_ACTIVE_EMPLOYEES', 'Busy.'),
    );
    await expectLater(
      StoreService(api).delete('s1'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          'STORE_HAS_ACTIVE_EMPLOYEES',
        ),
      ),
    );
  });

  test(
    'sales: list with store and date filters, page and totals; create',
    () async {
      final sales = SalesService(api);
      backend.json(
        'GET',
        '/api/sales/store/s1',
        ApiJson.page([ApiJson.sale()], pages: 3, totalAmount: '1250.50'),
      );
      final page = await sales.list(
        storeId: 's1',
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 18),
        page: 2,
      );
      expect(page.items.single.amount, 1250.5);
      expect(page.totalAmount, 1250.5);
      expect(page.hasMore, isTrue);
      expect(backend.requests.single.url.queryParameters, {
        'startDate': '2026-11-01',
        'endDate': '2026-11-18',
        'page': '2',
        'limit': '20',
        'sort': '-saleDate',
      });
      backend.json('POST', '/api/sales', ApiJson.sale(), status: 201);
      await sales.create(
        SaleCreateModel(
          storeId: 's1',
          amount: 1250.5,
          saleDate: DateTime(2026, 11, 18),
        ),
      );
      expect(_body(backend, 'POST', '/api/sales'), {
        'storeId': 's1',
        'amount': '1250.50',
        'saleDate': '2026-11-18',
      });
    },
  );

  test('employees: create', () async {
    backend.json('POST', '/api/employees', ApiJson.employee(), status: 201);
    final e = await EmployeeService(api).create(
      EmployeeCreateModel(
        fullName: 'Шерзод Рахимов',
        position: 'Продавец',
        storeId: 's1',
        monthlySalary: 3000,
        hiredAt: DateTime(2026, 1, 15),
      ),
    );
    expect(e.monthlySalary, 3000);
    expect(_body(backend, 'POST', '/api/employees'), {
      'fullName': 'Шерзод Рахимов',
      'position': 'Продавец',
      'storeId': 's1',
      'monthlySalary': '3000.00',
      'hiredAt': '2026-01-15',
      'status': 'ACTIVE',
    });
  });

  test('payroll: monthly report, salary payment, cancellation', () async {
    final payroll = PayrollService(api);
    backend.json('GET', '/api/payroll/monthly', ApiJson.monthlyPayroll());
    final month = await payroll.monthly(month: 11, year: 2026);
    expect(month.items.single.status.json, 'PARTIAL');
    expect(backend.requests.last.url.queryParameters, {
      'month': '11',
      'year': '2026',
    });
    backend.json('POST', '/api/payroll', ApiJson.payment(), status: 201);
    final paid = await payroll.pay(
      PaymentCreateModel(
        employeeId: '55555555-5555-5555-5555-555555555555',
        amount: 2000,
        month: 11,
        year: 2026,
        paymentDate: DateTime(2026, 11, 18),
      ),
    );
    expect(paid.status.json, 'PAID');
    expect(paid.period.remainingAmount, 0);
    expect(_body(backend, 'POST', '/api/payroll'), {
      'employeeId': '55555555-5555-5555-5555-555555555555',
      'amount': '2000.00',
      'month': 11,
      'year': 2026,
      'paymentDate': '2026-11-18',
    });
    backend.json('DELETE', '/api/payroll/${paid.id}', null, status: 204);
    await payroll.cancel(paid.id);
    expect(backend.calls('DELETE', '/api/payroll/${paid.id}'), hasLength(1));
  });

  test('payroll refused: PAYROLL_AMOUNT_EXCEEDS_REMAINING', () async {
    backend.on(
      'POST',
      '/api/payroll',
      (_) => FakeBackend.error(
        422,
        'PAYROLL_AMOUNT_EXCEEDS_REMAINING',
        'Too much.',
      ),
    );
    await expectLater(
      PayrollService(api).pay(
        const PaymentCreateModel(
          employeeId: 'e',
          amount: 99999,
          month: 11,
          year: 2026,
        ),
      ),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          'PAYROLL_AMOUNT_EXCEEDS_REMAINING',
        ),
      ),
    );
  });

  test('reports: dashboard and store comparison', () async {
    backend.json('GET', '/api/reports/dashboard', ApiJson.dashboard());
    backend.json(
      'GET',
      '/api/reports/store-comparison',
      ApiJson.storeComparison(),
    );
    final reports = ReportsService(api);
    final d = await reports.dashboard();
    expect(d.monthSales, 112028);
    expect(d.topStore?.storeName, 'Бахор — Сомони');
    expect(d.today, DateTime(2026, 11, 18));
    final c = await reports.storeComparison();
    expect(c.stores.single.sharePercent, 71.4);
  });

  test('profile: avatar uploaded as multipart field "file"', () async {
    backend.json(
      'PATCH',
      '/api/profile/avatar',
      ApiJson.profile(avatar: 'https://cdn.test/a.jpg'),
    );
    final p = await ProfileService(
      api,
    ).uploadAvatar(Uint8List.fromList([1, 2, 3]), 'me.png');
    expect(p.avatar, 'https://cdn.test/a.jpg');
    expect(
      String.fromCharCodes(backend.requests.single.bodyBytes),
      contains('name="file"; filename="me.png"'),
    );
  });
}
