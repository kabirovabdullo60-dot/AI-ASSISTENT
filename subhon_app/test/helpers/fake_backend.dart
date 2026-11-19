import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A fake of Mehroj's backend for tests (`MockClient`): responses are the
/// JSON shapes of API.md. The live server is never called.
class FakeBackend {
  FakeBackend() {
    client = MockClient(handle);
  }

  late final MockClient client;

  /// Every request received, in order.
  final requests = <http.Request>[];

  /// `METHOD /path` → handler. Unknown routes answer 404 `NOT_FOUND`.
  final routes = <String, http.Response Function(http.Request request)>{};

  void on(
    String method,
    String path,
    http.Response Function(http.Request request) handler,
  ) => routes['$method $path'] = handler;

  /// The same JSON for every call of a route.
  void json(String method, String path, Object? body, {int status = 200}) =>
      on(method, path, (_) => respond(body, status: status));

  List<http.Request> calls(String method, String path) => [
    for (final r in requests)
      if (r.method == method && r.url.path == path) r,
  ];

  Future<http.Response> handle(http.Request request) async {
    requests.add(request);
    final handler = routes['${request.method} ${request.url.path}'];
    if (handler == null) {
      return error(404, 'NOT_FOUND', 'Not found.');
    }
    return handler(request);
  }

  static http.Response respond(Object? body, {int status = 200}) =>
      http.Response.bytes(
        body == null ? const [] : utf8.encode(jsonEncode(body)),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

  /// The documented error body.
  static http.Response error(
    int status,
    String code,
    String message, {
    List<Map<String, String>> details = const [],
  }) => respond({
    'error': {
      'code': code,
      'message': message,
      'details': details,
      'meta': <String, Object>{},
      'requestId': 'req-test',
    },
  }, status: status);
}

/// JSON samples matching the API.md schemas.
abstract final class ApiJson {
  static Map<String, Object?> profile({
    String fullName = 'Фарход Назаров',
    String? avatar,
  }) => {
    'id': '11111111-1111-1111-1111-111111111111',
    'fullName': fullName,
    'email': 'farhod@bahor.tj',
    'phone': '+992935551020',
    'avatar': avatar,
    'role': 'OWNER',
    'business': {
      'id': '22222222-2222-2222-2222-222222222222',
      'name': 'Магазин «Бахор»',
    },
    'createdAt': '2026-11-01T05:00:00Z',
  };

  static Map<String, Object?> auth({
    String access = 'access-1',
    String refresh = 'refresh-1',
  }) => {
    'accessToken': access,
    'refreshToken': refresh,
    'tokenType': 'Bearer',
    'expiresIn': 1800,
    'refreshExpiresIn': 2592000,
    'user': profile(),
  };

  static Map<String, Object?> tokens(String access, String refresh) => {
    'accessToken': access,
    'refreshToken': refresh,
    'tokenType': 'Bearer',
    'expiresIn': 1800,
    'refreshExpiresIn': 2592000,
  };

  static Map<String, Object?> store({
    String id = '33333333-3333-3333-3333-333333333333',
    String name = 'Бахор — Сомони',
    String status = 'ACTIVE',
  }) => {
    'id': id,
    'name': name,
    'address': 'пр. Рӯдакӣ, 45',
    'phone': '+992901234567',
    'description': null,
    'status': status,
    'createdAt': '2026-10-01T05:00:00Z',
    'updatedAt': '2026-10-01T05:00:00Z',
    'deletedAt': null,
  };

  static Map<String, Object?> page(
    List<Object?> items, {
    int page = 1,
    int pages = 1,
    String? totalAmount,
  }) => {
    'items': items,
    'total': items.length,
    'page': page,
    'limit': 20,
    'pages': pages,
    'totalAmount': ?totalAmount,
  };

  static Map<String, Object?> expense({
    String id = '55555555-5555-5555-5555-555555555555',
    String category = 'RENT',
    String amount = '3000.00',
    String? storeId,
    String? storeName,
    String? description = 'Аренда за ноябрь',
  }) => {
    'id': id,
    'storeId': storeId,
    'storeName': storeName,
    'category': category,
    'amount': amount,
    'expenseDate': '2026-11-05',
    'description': description,
    'registeredById': '11111111-1111-1111-1111-111111111111',
    'registeredByName': 'Фарход Назаров',
    'createdAt': '2026-11-05T06:00:00Z',
    'updatedAt': '2026-11-05T06:00:00Z',
  };

  static Map<String, Object?> sale({
    String id = '44444444-4444-4444-4444-444444444444',
    String amount = '1250.50',
    String saleDate = '2026-11-18',
  }) => {
    'id': id,
    'storeId': '33333333-3333-3333-3333-333333333333',
    'storeName': 'Бахор — Сомони',
    'amount': amount,
    'saleDate': saleDate,
    'description': 'Выручка за смену',
    'createdAt': '2026-11-18T10:00:00Z',
    'updatedAt': '2026-11-18T10:00:00Z',
  };

  static Map<String, Object?> employee({
    String id = '55555555-5555-5555-5555-555555555555',
  }) => {
    'id': id,
    'fullName': 'Шерзод Рахимов',
    'phone': '+992900000000',
    'position': 'Продавец',
    'storeId': '33333333-3333-3333-3333-333333333333',
    'storeName': 'Бахор — Сомони',
    'monthlySalary': '3000.00',
    'hiredAt': '2026-01-15',
    'terminatedAt': null,
    'status': 'ACTIVE',
    'monthsWorked': 11,
    'createdAt': '2026-01-15T05:00:00Z',
    'updatedAt': '2026-01-15T05:00:00Z',
    'deletedAt': null,
  };

  static Map<String, Object?> period(String start, String end, int days) => {
    'startDate': start,
    'endDate': end,
    'days': days,
  };

  static Map<String, Object?> salesReport({String total = '6940.50'}) => {
    'currency': 'TJS',
    'period': period('2026-11-18', '2026-11-18', 1),
    'previousPeriod': period('2026-11-17', '2026-11-17', 1),
    'totalAmount': total,
    'salesCount': 3,
    'averageSaleAmount': '2313.50',
    'previousTotalAmount': '6000.00',
    'previousSalesCount': 2,
    'changeAmount': '940.50',
    'changePercent': 15.68,
    'storesCount': 1,
    'stores': <Object>[],
    'byDay': [
      {'saleDate': '2026-11-18', 'totalAmount': total, 'salesCount': 3},
    ],
  };

  static Map<String, Object?> dashboard({
    String? weekTarget,
    String? monthTarget = '150000.00',
  }) => {
    'currency': 'TJS',
    'today': '2026-11-18',
    'weekStartDate': '2026-11-16',
    'year': 2026,
    'month': 11,
    'totalStores': 3,
    'activeStores': 2,
    'inactiveStores': 1,
    'totalEmployees': 7,
    'activeEmployees': 6,
    'todaySales': '6940.50',
    'todaySalesCount': 3,
    'weekSales': '21000.00',
    'weekSalesCount': 12,
    'monthSales': '112028.00',
    'monthSalesCount': 64,
    'salaryDueThisMonth': '18000.00',
    'paidSalaryThisMonth': '9000.00',
    'remainingSalaryThisMonth': '9000.00',
    'remainingSalaryTotal': '12000.00',
    'topStore': {
      'storeId': '33333333-3333-3333-3333-333333333333',
      'storeName': 'Бахор — Сомони',
      'totalAmount': '80000.00',
      'salesCount': 40,
    },
    'monthExpenses': '12000.00',
    'monthProfit': '82028.00',
    'monthMarginPercent': 73.22,
    'weekTarget': weekTarget,
    'monthTarget': monthTarget,
  };

  static Map<String, Object?> storeComparison() => {
    'currency': 'TJS',
    'period': period('2026-11-01', '2026-11-18', 18),
    'previousPeriod': period('2026-10-14', '2026-10-31', 18),
    'totalAmount': '112028.00',
    'salesCount': 64,
    'storesCount': 1,
    'bestStore': null,
    'stores': [
      {
        'storeId': '33333333-3333-3333-3333-333333333333',
        'storeName': 'Бахор — Сомони',
        'status': 'ACTIVE',
        'isDeleted': false,
        'totalAmount': '80000.00',
        'salesCount': 40,
        'averageSaleAmount': '2000.00',
        'sharePercent': 71.4,
        'previousTotalAmount': '70000.00',
        'previousSalesCount': 35,
        'changeAmount': '10000.00',
        'changePercent': 14.29,
        'rank': 1,
        'activeEmployees': 4,
      },
    ],
  };

  static Map<String, Object?> monthlyPayroll({String status = 'PARTIAL'}) => {
    'currency': 'TJS',
    'year': 2026,
    'month': 11,
    'employeesCount': 1,
    'totalDue': '3000.00',
    'totalPaid': '1000.00',
    'totalRemaining': '2000.00',
    'paidCount': 0,
    'partialCount': 1,
    'unpaidCount': 0,
    'items': [
      {
        'employeeId': '55555555-5555-5555-5555-555555555555',
        'fullName': 'Шерзод Рахимов',
        'position': 'Продавец',
        'storeId': '33333333-3333-3333-3333-333333333333',
        'storeName': 'Бахор — Сомони',
        'employeeStatus': 'ACTIVE',
        'isDeleted': false,
        'monthlySalary': '3000.00',
        'workedDays': 30,
        'dueAmount': '3000.00',
        'paidAmount': '1000.00',
        'remainingAmount': '2000.00',
        'status': status,
        'paymentsCount': 1,
      },
    ],
  };

  static Map<String, Object?> payment({String amount = '2000.00'}) => {
    'id': '66666666-6666-6666-6666-666666666666',
    'employeeId': '55555555-5555-5555-5555-555555555555',
    'employeeName': 'Шерзод Рахимов',
    'amount': amount,
    'month': 11,
    'year': 2026,
    'paymentDate': '2026-11-18',
    'status': 'PAID',
    'note': null,
    'period': {
      'dueAmount': '3000.00',
      'paidAmount': '3000.00',
      'remainingAmount': '0.00',
    },
    'createdAt': '2026-11-18T10:00:00Z',
  };

  static Map<String, Object?> employeesReport() => {
    'currency': 'TJS',
    'totalEmployees': 7,
    'activeEmployees': 6,
    'inactiveEmployees': 1,
    'hiredThisMonth': 1,
    'monthlySalaryTotal': '18000.00',
    'averageMonthlySalary': '3000.00',
    'byStore': <Object>[],
    'byPosition': <Object>[],
  };

  static Map<String, Object?> payrollYear() => {
    'currency': 'TJS',
    'year': 2026,
    'totalDue': '18000.00',
    'totalPaid': '9000.00',
    'totalRemaining': '9000.00',
    'months': <Object>[],
  };

  static Map<String, Object?> profit({
    String gross = '82028.00',
    double? margin = 73.22,
  }) => {
    'currency': 'TJS',
    'period': period('2026-11-01', '2026-11-18', 18),
    'salesTotal': '112028.00',
    'expensesTotal': '12000.00',
    'salaryDue': '18000.00',
    'grossProfit': gross,
    'marginPercent': margin,
    'byCategory': [
      {'category': 'RENT', 'totalAmount': '9000.00'},
      {'category': 'UTILITIES', 'totalAmount': '3000.00'},
    ],
    'byStore': [
      {
        'storeId': '33333333-3333-3333-3333-333333333333',
        'storeName': 'Бахор — Сомони',
        'salesTotal': '112028.00',
        'expensesTotal': '3000.00',
        'salaryDue': '18000.00',
        'profit': '91028.00',
      },
      {
        'storeId': null,
        'storeName': null,
        'salesTotal': '0.00',
        'expensesTotal': '9000.00',
        'salaryDue': '0.00',
        'profit': '-9000.00',
      },
    ],
  };

  static Map<String, Object?> activity({
    String type = 'SALE',
    String action = 'CREATED',
    String entityName = 'Бахор — Сомони',
    String? amount = '1250.50',
    String? status,
  }) => {
    'id':
        '77777777-7777-7777-7777-${(type + action).hashCode.abs().toString().padLeft(12, '0').substring(0, 12)}',
    'type': type,
    'action': action,
    'entityId': '44444444-4444-4444-4444-444444444444',
    'entityName': entityName,
    'storeId': '33333333-3333-3333-3333-333333333333',
    'storeName': 'Бахор — Сомони',
    'employeeId': null,
    'amount': amount,
    'note': null,
    'changedFields': null,
    'status': status,
    'period': null,
    'actorId': '11111111-1111-1111-1111-111111111111',
    'actorName': 'Фарход Назаров',
    'createdAt': '2026-11-18T09:05:00Z',
  };

  static Map<String, Object?> notifications({int unread = 2}) => {
    'items': [
      {
        'id': '88888888-8888-8888-8888-888888888881',
        'kind': 'SALARY_OVERDUE',
        'severity': 'WARNING',
        'count': 2,
        'amount': '6000.00',
        'storeId': null,
        'storeName': null,
        'link': 'PAYROLL',
        'read': false,
        'createdAt': '2026-11-01T00:00:00Z',
      },
      {
        'id': '88888888-8888-8888-8888-888888888882',
        'kind': 'STORE_NO_SALES_TODAY',
        'severity': 'INFO',
        'count': 1,
        'amount': null,
        'storeId': '33333333-3333-3333-3333-333333333333',
        'storeName': 'Бахор — Сомони',
        'link': 'SALES',
        'read': unread < 2,
        'createdAt': '2026-11-18T00:00:00Z',
      },
    ],
    'unreadCount': unread,
    'lastReadAt': null,
  };
}
