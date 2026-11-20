import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// In-memory copy of Mehroj's API (same paths, JSON shapes and error codes as the Swagger),
/// so widget tests exercise the real services, models and HTTP client.
class FakeBackend {
  FakeBackend() {
    _seed();
  }

  // ---------- state ----------
  final users = <Map<String, dynamic>>[];
  final stores = <Map<String, dynamic>>[];
  final sales = <Map<String, dynamic>>[];
  final employees = <Map<String, dynamic>>[];
  final payments = <Map<String, dynamic>>[];
  final requests = <String>[];

  /// Rows of GET /api/activity (`ActivityOut`), newest first. Empty → the dashboard falls back to sales + payments.
  final activity = <Map<String, dynamic>>[];

  /// Answer of POST /api/assistant/chat. Null → `503 ASSISTANT_UNAVAILABLE` (AI not configured).
  String? assistantReply;

  /// `AssistantActionOut` rows the next chat answer proposes (then kept in [actions] by id).
  List<Map<String, dynamic>> nextActions = [];

  /// Every proposed action by id (POST /api/assistant/actions/{id}/confirm|cancel, GET).
  final actions = <String, Map<String, dynamic>>{};

  /// Builds an `AssistantActionOut` in PROPOSED state.
  Map<String, dynamic> proposeAction(
    String type,
    Map<String, dynamic> params, {
    String? summary,
    bool expired = false,
  }) {
    final now = DateTime.now().toUtc();
    return {
      'id': _id('act'),
      'type': type,
      'status': 'PROPOSED',
      'summary': summary ?? '$type ${params['name'] ?? ''}'.trim(),
      'danger': type.startsWith('DELETE_'),
      'params': params,
      'result': null,
      'error': null,
      'createdAt': now.toIso8601String(),
      'expiresAt': (expired ? now.subtract(const Duration(minutes: 1)) : now.add(const Duration(minutes: 30)))
          .toIso8601String(),
    };
  }

  /// When true, POST /api/assistant/chat answers `429 RATE_LIMITED`.
  bool assistantRateLimited = false;

  /// GET /api/notifications rows (`NotificationOut`); read-all marks them read.
  final notifications = <Map<String, dynamic>>[];

  /// /api/expenses rows (`ExpenseOut` + `deleted`).
  final expenses = <Map<String, dynamic>>[];

  /// Business-wide sales targets set with PUT /api/targets: `{'WEEK': '5000.00'}`.
  final targets = <String, String>{};

  /// Delay before every answer (to see loading states in tests). Zero = instant.
  Duration latency = Duration.zero;

  /// GET /api/settings/exchange-rates.
  String usdRate = '10.95';

  /// Last body sent to POST /api/assistant/chat.
  Map<String, dynamic>? lastChatRequest;

  String? accessToken;
  String? refreshToken;
  int _n = 100;

  /// The next authorized request answers `401 AUTH_TOKEN_EXPIRED` (tests the refresh flow).
  bool expireAccessOnce = false;

  static const password = 'secret123';

  DateTime get today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  http.Client get client => MockClient(_handle);

  String _id(String p) => '$p-${_n++}';
  static String day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static DateTime parseDay(String s) => DateTime.parse(s);
  static String money(num v) => v.toStringAsFixed(2);

  void _seed() {
    users.add({
      'id': 'u-1',
      'fullName': 'Abdullo Kabirov',
      'email': 'owner@test.tj',
      'phone': '+992900000000',
      'avatar': null,
      'role': 'OWNER',
      'business': {'id': 'b-1', 'name': 'Apex Test'},
      'createdAt': '2025-01-01T00:00:00Z',
    });
    final now = DateTime.now().toUtc().toIso8601String();
    stores.addAll([
      {
        'id': 's1',
        'name': 'Central Plaza',
        'address': '45 Rudaki Ave',
        'phone': '+992901234567',
        'description': 'Flagship',
        'status': 'ACTIVE',
        'createdAt': now,
        'updatedAt': now,
        'deletedAt': null,
      },
      {
        'id': 's2',
        'name': 'Somoni Branch',
        'address': '112 Somoni St',
        'phone': null,
        'description': null,
        'status': 'ACTIVE',
        'createdAt': now,
        'updatedAt': now,
        'deletedAt': null,
      },
      {
        'id': 's3',
        'name': 'Bokhtar Express',
        'address': '22 Vakhsh Ave',
        'phone': null,
        'description': 'Renovation',
        'status': 'INACTIVE',
        'createdAt': now,
        'updatedAt': now,
        'deletedAt': null,
      },
    ]);
    for (var d = 0; d < 30; d++) {
      final date = today.subtract(Duration(days: d));
      sales.add(_sale('s1', 1000 + d * 10, date, d == 0 ? 'POS + Cash' : null));
      sales.add(_sale('s2', 500 + d * 5, date, null));
    }
    employees.addAll([
      _employee('e1', 'Davron Aliev', 'Store Manager', 's1', 4500),
      _employee('e2', 'Malika Karimova', 'Cashier', 's1', 3200),
      _employee('e3', 'Farrukh Nazarov', 'Sales Associate', 's2', 2800),
      _employee('e4', 'Old Worker', 'Cashier', 's3', 2000, active: false),
    ]);
    payments.add(_payment('e1', 4500, today.month, today.year));
    payments.add(_payment('e3', 1800, today.month, today.year));
  }

  Map<String, dynamic> _sale(String storeId, num amount, DateTime date, String? description) => {
    'id': _id('sale'),
    'storeId': storeId,
    'amount': money(amount),
    'saleDate': day(date),
    'description': description,
    'createdAt': date.add(const Duration(hours: 12)).toUtc().toIso8601String(),
    'updatedAt': date.toUtc().toIso8601String(),
    'deleted': false,
  };

  Map<String, dynamic> _employee(
    String id,
    String name,
    String position,
    String storeId,
    num salary, {
    bool active = true,
  }) => {
    'id': id,
    'fullName': name,
    'phone': null,
    'position': position,
    'storeId': storeId,
    'monthlySalary': money(salary),
    'hiredAt': active ? '2025-01-01' : '2024-01-01',
    'terminatedAt': active ? null : '2024-12-31',
    'status': active ? 'ACTIVE' : 'INACTIVE',
    'createdAt': '2025-01-01T00:00:00Z',
    'updatedAt': '2025-01-01T00:00:00Z',
    'deletedAt': null,
  };

  Map<String, dynamic> _payment(String employeeId, num amount, int month, int year, {String? note, DateTime? date}) => {
    'id': _id('pay'),
    'employeeId': employeeId,
    'amount': money(amount),
    'month': month,
    'year': year,
    'paymentDate': day(date ?? today),
    'note': note,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
    'deleted': false,
  };

  // ---------- helpers ----------
  http.Response _json(Object? body, [int status = 200]) => http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  http.Response _error(int status, String code, [List<Map<String, String>> details = const []]) => _json({
    'error': {'code': code, 'message': code, 'details': details, 'meta': {}, 'requestId': 'test'},
  }, status);

  Map<String, dynamic> get user => users.first;
  Map<String, dynamic>? _store(String id) => stores.where((s) => s['id'] == id && s['deletedAt'] == null).firstOrNull;
  Map<String, dynamic>? _emp(String id) => employees.where((e) => e['id'] == id && e['deletedAt'] == null).firstOrNull;
  Iterable<Map<String, dynamic>> get _liveSales => sales.where((s) => s['deleted'] != true);
  Iterable<Map<String, dynamic>> get _livePayments => payments.where((p) => p['deleted'] != true);
  double _amount(Map<String, dynamic> m) => double.parse('${m['amount']}');

  Map<String, dynamic> _saleOut(Map<String, dynamic> s) => {
    ...Map.of(s)..remove('deleted'),
    'storeName': stores.firstWhere((x) => x['id'] == s['storeId'])['name'],
  };

  Map<String, dynamic> _employeeOut(Map<String, dynamic> e) => {
    ...e,
    'storeName': stores.firstWhere((x) => x['id'] == e['storeId'])['name'],
    'monthsWorked': 10,
  };

  bool _employedIn(Map<String, dynamic> e, int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1, 0);
    final hired = parseDay(e['hiredAt'] as String);
    final left = e['terminatedAt'] == null ? null : parseDay(e['terminatedAt'] as String);
    return !hired.isAfter(end) && (left == null || !left.isBefore(start));
  }

  double _paidFor(String employeeId, int year, int month) => _livePayments
      .where((p) => p['employeeId'] == employeeId && p['year'] == year && p['month'] == month)
      .fold(0.0, (s, p) => s + _amount(p));

  Map<String, dynamic> _paymentOut(Map<String, dynamic> p) {
    final e = employees.firstWhere((x) => x['id'] == p['employeeId']);
    final due = double.parse('${e['monthlySalary']}');
    final paid = _paidFor(p['employeeId'] as String, p['year'] as int, p['month'] as int);
    return {
      ...Map.of(p)..remove('deleted'),
      'employeeName': e['fullName'],
      'status': paid >= due ? 'PAID' : (paid > 0 ? 'PARTIAL' : 'UNPAID'),
      'period': {'dueAmount': money(due), 'paidAmount': money(paid), 'remainingAmount': money(due - paid)},
    };
  }

  Map<String, dynamic> _page(List<Object?> items, Map<String, String> q, {String? totalAmount}) {
    final page = int.tryParse(q['page'] ?? '') ?? 1;
    final limit = int.tryParse(q['limit'] ?? '') ?? 20;
    final start = ((page - 1) * limit).clamp(0, items.length);
    return {
      'items': items.sublist(start, (start + limit).clamp(0, items.length)),
      'total': items.length,
      'page': page,
      'limit': limit,
      'pages': items.isEmpty ? 0 : (items.length / limit).ceil(),
      'totalAmount': ?totalAmount,
    };
  }

  Map<String, dynamic> _report(DateTime from, DateTime to, {bool comparison = false}) {
    final days = to.difference(from).inDays + 1;
    final prevTo = from.subtract(const Duration(days: 1));
    final prevFrom = prevTo.subtract(Duration(days: days - 1));
    bool inRange(Map<String, dynamic> s, DateTime a, DateTime b) {
      final d = parseDay(s['saleDate'] as String);
      return !d.isBefore(a) && !d.isAfter(b);
    }

    final cur = _liveSales.where((s) => inRange(s, from, to)).toList();
    final prev = _liveSales.where((s) => inRange(s, prevFrom, prevTo)).toList();
    double sum(Iterable<Map<String, dynamic>> l) => l.fold(0.0, (a, s) => a + _amount(s));
    final total = sum(cur);
    final prevTotal = sum(prev);
    final rows = <Map<String, dynamic>>[];
    for (final st in stores.where((s) => s['deletedAt'] == null)) {
      final mine = cur.where((s) => s['storeId'] == st['id']);
      final before = prev.where((s) => s['storeId'] == st['id']);
      final t = sum(mine);
      final p = sum(before);
      rows.add({
        'storeId': st['id'],
        'storeName': st['name'],
        'status': st['status'],
        'isDeleted': false,
        'totalAmount': money(t),
        'salesCount': mine.length,
        'averageSaleAmount': money(mine.isEmpty ? 0 : t / mine.length),
        'sharePercent': total == 0 ? 0 : t / total * 100,
        'previousTotalAmount': money(p),
        'previousSalesCount': before.length,
        'changeAmount': money(t - p),
        'changePercent': p == 0 ? null : (t - p) / p * 100,
        'activeEmployees': employees
            .where((e) => e['storeId'] == st['id'] && e['status'] == 'ACTIVE' && e['deletedAt'] == null)
            .length,
      });
    }
    rows.sort((a, b) => double.parse('${b['totalAmount']}').compareTo(double.parse('${a['totalAmount']}')));
    for (var i = 0; i < rows.length; i++) {
      rows[i]['rank'] = i + 1;
    }
    final byDay = <String, List<Map<String, dynamic>>>{};
    for (final s in cur) {
      byDay.putIfAbsent(s['saleDate'] as String, () => []).add(s);
    }
    return {
      'currency': 'TJS',
      'period': {'startDate': day(from), 'endDate': day(to), 'days': days},
      'previousPeriod': {'startDate': day(prevFrom), 'endDate': day(prevTo), 'days': days},
      'totalAmount': money(total),
      'salesCount': cur.length,
      'averageSaleAmount': money(cur.isEmpty ? 0 : total / cur.length),
      'previousTotalAmount': money(prevTotal),
      'previousSalesCount': prev.length,
      'changeAmount': money(total - prevTotal),
      'changePercent': prevTotal == 0 ? null : (total - prevTotal) / prevTotal * 100,
      'storesCount': rows.length,
      'stores': rows,
      'bestStore': comparison && rows.isNotEmpty ? rows.first : null,
      'byDay': [
        for (final e in (byDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key))))
          {'saleDate': e.key, 'totalAmount': money(sum(e.value)), 'salesCount': e.value.length},
      ],
    };
  }

  Map<String, dynamic> _monthlyPayroll(int year, int month, String? storeId) {
    final rows = <Map<String, dynamic>>[];
    for (final e in employees.where((e) => e['deletedAt'] == null && _employedIn(e, year, month))) {
      if (storeId != null && e['storeId'] != storeId) continue;
      final due = double.parse('${e['monthlySalary']}');
      final paid = _paidFor(e['id'] as String, year, month);
      rows.add({
        'employeeId': e['id'],
        'fullName': e['fullName'],
        'position': e['position'],
        'storeId': e['storeId'],
        'storeName': stores.firstWhere((s) => s['id'] == e['storeId'])['name'],
        'employeeStatus': e['status'],
        'isDeleted': false,
        'monthlySalary': money(due),
        'workedDays': 30,
        'dueAmount': money(due),
        'paidAmount': money(paid),
        'remainingAmount': money(due - paid),
        'status': paid >= due ? 'PAID' : (paid > 0 ? 'PARTIAL' : 'UNPAID'),
        'paymentsCount': _livePayments
            .where((p) => p['employeeId'] == e['id'] && p['month'] == month && p['year'] == year)
            .length,
      });
    }
    double sum(String k) => rows.fold(0.0, (a, r) => a + double.parse('${r[k]}'));
    return {
      'currency': 'TJS',
      'year': year,
      'month': month,
      'employeesCount': rows.length,
      'totalDue': money(sum('dueAmount')),
      'totalPaid': money(sum('paidAmount')),
      'totalRemaining': money(sum('remainingAmount')),
      'paidCount': rows.where((r) => r['status'] == 'PAID').length,
      'partialCount': rows.where((r) => r['status'] == 'PARTIAL').length,
      'unpaidCount': rows.where((r) => r['status'] == 'UNPAID').length,
      'items': rows,
    };
  }

  Map<String, dynamic> _tokens() {
    accessToken = 'access-${_n++}';
    refreshToken = 'refresh-${_n++}';
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': 'bearer',
      'expiresIn': 1800,
      'refreshExpiresIn': 2592000,
    };
  }

  // ---------- router ----------
  Future<http.Response> _handle(http.Request r) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final path = r.url.path;
    final q = r.url.queryParameters;
    final m = r.method;
    requests.add('$m $path');
    Map<String, dynamic> body() => r.body.isEmpty || !(r.headers['content-type'] ?? '').contains('json')
        ? {}
        : Map<String, dynamic>.from(jsonDecode(r.body) as Map);

    if (path == '/health/ready') {
      return _json({
        'status': 'ok',
        'checks': {'database': 'ok'},
      });
    }

    // auth (no token)
    if (path == '/api/auth/login' && m == 'POST') {
      final b = body();
      if (b['email'] != user['email'] || b['password'] != password) return _error(401, 'AUTH_INVALID_CREDENTIALS');
      return _json({..._tokens(), 'user': user});
    }
    if (path == '/api/auth/register' && m == 'POST') {
      final b = body();
      if (users.any((u) => u['email'] == b['email'])) return _error(409, 'EMAIL_ALREADY_REGISTERED');
      users.insert(0, {
        'id': _id('u'),
        'fullName': b['fullName'],
        'email': b['email'],
        'phone': b['phone'],
        'avatar': null,
        'role': 'OWNER',
        'business': {'id': _id('b'), 'name': b['businessName'] ?? "${b['fullName']}'s business"},
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
      stores.clear();
      sales.clear();
      employees.clear();
      payments.clear();
      return _json({..._tokens(), 'user': user}, 201);
    }
    if (path == '/api/auth/refresh' && m == 'POST') {
      if (body()['refreshToken'] != refreshToken || refreshToken == null) return _error(401, 'AUTH_SESSION_REVOKED');
      expireAccessOnce = false;
      return _json(_tokens());
    }

    // everything below needs a valid access token
    final auth = r.headers['Authorization'] ?? r.headers['authorization'];
    if (auth == null) return _error(401, 'AUTH_REQUIRED');
    if (expireAccessOnce) return _error(401, 'AUTH_TOKEN_EXPIRED');
    if (auth != 'Bearer $accessToken') return _error(401, 'AUTH_TOKEN_INVALID');

    if (path == '/api/auth/logout' && m == 'POST') {
      accessToken = null;
      refreshToken = null;
      return http.Response('', 204);
    }
    if (path == '/api/auth/me' || (path == '/api/profile' && m == 'GET')) return _json(user);
    if (path == '/api/profile' && m == 'PUT') {
      final b = body();
      for (final k in ['fullName', 'email', 'phone']) {
        if (b.containsKey(k)) user[k] = b[k];
      }
      if (b['businessName'] != null) user['business'] = {...user['business'] as Map, 'name': b['businessName']};
      return _json(user);
    }
    if (path == '/api/profile/password' && m == 'PATCH') {
      if (body()['currentPassword'] != password) return _error(422, 'CURRENT_PASSWORD_INCORRECT');
      return http.Response('', 204);
    }
    if (path == '/api/profile/avatar' && m == 'PATCH') {
      user['avatar'] = '/media/avatar.png';
      return _json(user);
    }

    // stores
    if (path == '/api/stores' && m == 'GET') {
      final list = stores.where((s) => s['deletedAt'] == null).toList()
        ..sort((a, b) => '${a['name']}'.compareTo('${b['name']}'));
      return _json(_page(list, q));
    }
    if (path == '/api/stores' && m == 'POST') {
      final b = body();
      if (stores.any((s) => s['deletedAt'] == null && s['name'] == b['name'])) return _error(409, 'STORE_NAME_TAKEN');
      final now = DateTime.now().toUtc().toIso8601String();
      final s = {
        'id': _id('s'),
        ...b,
        'status': b['status'] ?? 'ACTIVE',
        'createdAt': now,
        'updatedAt': now,
        'deletedAt': null,
      };
      stores.add(s);
      return _json(s, 201);
    }
    final storeMatch = RegExp(r'^/api/stores/([^/]+)$').firstMatch(path);
    if (storeMatch != null) {
      final s = _store(storeMatch.group(1)!);
      if (s == null) return _error(404, 'STORE_NOT_FOUND');
      if (m == 'GET') return _json(s);
      if (m == 'PUT') {
        s.addAll(body());
        s['updatedAt'] = DateTime.now().toUtc().toIso8601String();
        return _json(s);
      }
      if (m == 'DELETE') {
        if (employees.any((e) => e['storeId'] == s['id'] && e['status'] == 'ACTIVE' && e['deletedAt'] == null)) {
          return _error(409, 'STORE_HAS_ACTIVE_EMPLOYEES');
        }
        s['deletedAt'] = DateTime.now().toUtc().toIso8601String();
        return http.Response('', 204);
      }
    }

    // sales reports
    if (path == '/api/sales/daily') {
      final d = q['date'] == null ? today : parseDay(q['date']!);
      return _json(_report(d, d));
    }
    if (path == '/api/sales/weekly' || path == '/api/reports/weekly-sales') {
      final to = q['endDate'] == null ? today : parseDay(q['endDate']!);
      final from = q['startDate'] == null ? to.subtract(const Duration(days: 6)) : parseDay(q['startDate']!);
      return _json(_report(from, to));
    }
    if (path == '/api/sales/monthly' || path == '/api/reports/monthly-sales') {
      final y = int.tryParse(q['year'] ?? '') ?? today.year;
      final mo = int.tryParse(q['month'] ?? '') ?? today.month;
      final end = DateTime(y, mo + 1, 0);
      return _json(_report(DateTime(y, mo), end.isAfter(today) ? today : end));
    }
    if (path == '/api/reports/store-comparison') {
      final to = q['endDate'] == null ? today : parseDay(q['endDate']!);
      final from = q['startDate'] == null ? DateTime(to.year, to.month) : parseDay(q['startDate']!);
      return _json(_report(from, to, comparison: true));
    }

    // sales
    final salesOfStore = RegExp(r'^/api/sales/store/([^/]+)$').firstMatch(path);
    if ((path == '/api/sales' || salesOfStore != null) && m == 'GET') {
      final storeId = salesOfStore?.group(1) ?? q['storeId'];
      var list = _liveSales.where((s) => storeId == null || s['storeId'] == storeId).where((s) {
        final d = parseDay(s['saleDate'] as String);
        return (q['startDate'] == null || !d.isBefore(parseDay(q['startDate']!))) &&
            (q['endDate'] == null || !d.isAfter(parseDay(q['endDate']!)));
      }).toList();
      final sort = (q['sort'] ?? '-saleDate').split(',').first;
      final key = sort.replaceFirst('-', '');
      list.sort((a, b) => '${b[key]}'.compareTo('${a[key]}'));
      if (!sort.startsWith('-')) list = list.reversed.toList();
      final total = list.fold(0.0, (a, s) => a + _amount(s));
      return _json(_page(list.map(_saleOut).toList(), q, totalAmount: money(total)));
    }
    if (path == '/api/sales' && m == 'POST') {
      final b = body();
      if (_store('${b['storeId']}') == null) return _error(404, 'STORE_NOT_FOUND');
      final date = b['saleDate'] == null ? today : parseDay('${b['saleDate']}');
      if (date.isAfter(today)) return _error(422, 'SALE_DATE_IN_FUTURE');
      final s = _sale('${b['storeId']}', double.parse('${b['amount']}'), date, b['description'] as String?);
      s['createdAt'] = DateTime.now().toUtc().toIso8601String();
      sales.add(s);
      return _json(_saleOut(s), 201);
    }
    final saleMatch = RegExp(r'^/api/sales/([^/]+)$').firstMatch(path);
    if (saleMatch != null) {
      final s = _liveSales.where((x) => x['id'] == saleMatch.group(1)).firstOrNull;
      if (s == null) return _error(404, 'SALE_NOT_FOUND');
      if (m == 'GET') return _json(_saleOut(s));
      if (m == 'PUT') {
        final b = body();
        for (final k in ['storeId', 'amount', 'saleDate', 'description']) {
          if (b.containsKey(k)) s[k] = k == 'amount' ? money(double.parse('${b[k]}')) : b[k];
        }
        return _json(_saleOut(s));
      }
      if (m == 'DELETE') {
        s['deleted'] = true;
        return http.Response('', 204);
      }
    }

    // employees
    final empOfStore = RegExp(r'^/api/employees/store/([^/]+)$').firstMatch(path);
    if ((path == '/api/employees' || empOfStore != null) && m == 'GET') {
      final storeId = empOfStore?.group(1) ?? q['storeId'];
      final list =
          employees
              .where((e) => e['deletedAt'] == null && (storeId == null || e['storeId'] == storeId))
              .map(_employeeOut)
              .toList()
            ..sort((a, b) => '${a['fullName']}'.compareTo('${b['fullName']}'));
      return _json(_page(list, q));
    }
    if (path == '/api/employees' && m == 'POST') {
      final b = body();
      final e = {..._employee(_id('e'), '', '', '${b['storeId']}', 0), ...b};
      e['monthlySalary'] = money(double.parse('${b['monthlySalary']}'));
      employees.add(e);
      return _json(_employeeOut(e), 201);
    }
    final empMatch = RegExp(r'^/api/employees/([^/]+)$').firstMatch(path);
    if (empMatch != null) {
      final e = _emp(empMatch.group(1)!);
      if (e == null) return _error(404, 'EMPLOYEE_NOT_FOUND');
      if (m == 'GET') return _json(_employeeOut(e));
      if (m == 'PUT') {
        e.addAll(body());
        e['monthlySalary'] = money(double.parse('${e['monthlySalary']}'));
        return _json(_employeeOut(e));
      }
      if (m == 'DELETE') {
        e['deletedAt'] = DateTime.now().toUtc().toIso8601String();
        return http.Response('', 204);
      }
    }

    // payroll
    if (path == '/api/payroll/monthly') {
      return _json(
        _monthlyPayroll(
          int.tryParse(q['year'] ?? '') ?? today.year,
          int.tryParse(q['month'] ?? '') ?? today.month,
          q['storeId'],
        ),
      );
    }
    if (path == '/api/payroll' && m == 'GET') {
      final list =
          _livePayments
              .where((p) => q['month'] == null || '${p['month']}' == q['month'])
              .where((p) => q['year'] == null || '${p['year']}' == q['year'])
              .where((p) => q['employeeId'] == null || p['employeeId'] == q['employeeId'])
              .toList()
            ..sort((a, b) => '${b['createdAt']}'.compareTo('${a['createdAt']}'));
      final total = list.fold(0.0, (a, p) => a + _amount(p));
      return _json(_page(list.map(_paymentOut).toList(), q, totalAmount: money(total)));
    }
    if (path == '/api/payroll' && m == 'POST') {
      final b = body();
      final e = _emp('${b['employeeId']}');
      if (e == null) return _error(404, 'EMPLOYEE_NOT_FOUND');
      final y = b['year'] as int;
      final mo = b['month'] as int;
      if (DateTime(y, mo).isAfter(DateTime(today.year, today.month))) return _error(422, 'PAYROLL_PERIOD_IN_FUTURE');
      if (!_employedIn(e, y, mo)) return _error(422, 'EMPLOYEE_NOT_EMPLOYED_IN_PERIOD');
      final due = double.parse('${e['monthlySalary']}');
      final paid = _paidFor(e['id'] as String, y, mo);
      final amount = double.parse('${b['amount']}');
      if (paid >= due) return _error(409, 'PAYROLL_ALREADY_PAID');
      if (paid + amount > due + 0.001) return _error(422, 'PAYROLL_AMOUNT_EXCEEDS_REMAINING');
      final p = _payment(e['id'] as String, amount, mo, y, note: b['note'] as String?);
      payments.add(p);
      return _json(_paymentOut(p), 201);
    }
    final payOfEmp = RegExp(r'^/api/payroll/employee/([^/]+)$').firstMatch(path);
    if (payOfEmp != null) {
      final e = _emp(payOfEmp.group(1)!);
      if (e == null) return _error(404, 'EMPLOYEE_NOT_FOUND');
      final due = double.parse('${e['monthlySalary']}');
      final months = [
        for (var i = 2; i >= 0; i--)
          () {
            final d = DateTime(today.year, today.month - i);
            final paid = _paidFor(e['id'] as String, d.year, d.month);
            return {
              'year': d.year,
              'month': d.month,
              'monthlySalary': money(due),
              'workedDays': 30,
              'dueAmount': money(due),
              'paidAmount': money(paid),
              'remainingAmount': money(due - paid),
              'status': paid >= due ? 'PAID' : (paid > 0 ? 'PARTIAL' : 'UNPAID'),
              'paymentsCount': 0,
            };
          }(),
      ];
      double sum(String k) => months.fold(0.0, (a, x) => a + double.parse('${x[k]}'));
      return _json({
        'currency': 'TJS',
        'employee': {..._employeeOut(e), 'isDeleted': false},
        'monthlySalary': money(due),
        'monthsWorked': 10,
        'totalDue': money(sum('dueAmount')),
        'totalPaid': money(sum('paidAmount')),
        'totalRemaining': money(sum('remainingAmount')),
        'salaryHistory': [],
        'months': months,
        'payments': _livePayments.where((p) => p['employeeId'] == e['id']).map(_paymentOut).toList(),
      });
    }
    final payMatch = RegExp(r'^/api/payroll/([^/]+)$').firstMatch(path);
    if (payMatch != null) {
      final p = _livePayments.where((x) => x['id'] == payMatch.group(1)).firstOrNull;
      if (p == null) return _error(404, 'PAYROLL_NOT_FOUND');
      if (m == 'GET') return _json(_paymentOut(p));
      if (m == 'DELETE') {
        p['deleted'] = true;
        return http.Response('', 204);
      }
    }

    // reports
    if (path == '/api/reports/dashboard') {
      final daily = _report(today, today);
      final week = _report(today.subtract(const Duration(days: 6)), today);
      final month = _report(DateTime(today.year, today.month), today);
      final payroll = _monthlyPayroll(today.year, today.month, null);
      final live = stores.where((s) => s['deletedAt'] == null);
      final staff = employees.where((e) => e['deletedAt'] == null);
      final top = (month['stores'] as List).isEmpty ? null : (month['stores'] as List).first as Map;
      return _json({
        'currency': 'TJS',
        'today': day(today),
        'weekStartDate': day(today.subtract(const Duration(days: 6))),
        'year': today.year,
        'month': today.month,
        'totalStores': live.length,
        'activeStores': live.where((s) => s['status'] == 'ACTIVE').length,
        'inactiveStores': live.where((s) => s['status'] != 'ACTIVE').length,
        'totalEmployees': staff.length,
        'activeEmployees': staff.where((e) => e['status'] == 'ACTIVE').length,
        'todaySales': daily['totalAmount'],
        'todaySalesCount': daily['salesCount'],
        'weekSales': week['totalAmount'],
        'weekSalesCount': week['salesCount'],
        'monthSales': month['totalAmount'],
        'monthSalesCount': month['salesCount'],
        'salaryDueThisMonth': payroll['totalDue'],
        'paidSalaryThisMonth': payroll['totalPaid'],
        'remainingSalaryThisMonth': payroll['totalRemaining'],
        'remainingSalaryTotal': payroll['totalRemaining'],
        'topStore': top == null
            ? null
            : {
                'storeId': top['storeId'],
                'storeName': top['storeName'],
                'totalAmount': top['totalAmount'],
                'salesCount': top['salesCount'],
              },
        'monthExpenses': '0.00',
        'monthProfit': money(double.parse('${month['totalAmount']}') - 250),
        'monthMarginPercent': 12.5,
        'weekTarget': targets['WEEK'],
        'monthTarget': targets['MONTH'],
      });
    }
    if (path == '/api/targets' && m == 'PUT') {
      final b = body();
      final amount = double.tryParse('${b['amount']}') ?? 0;
      if (!['WEEK', 'MONTH'].contains(b['period']) || amount <= 0) return _error(422, 'VALIDATION_ERROR');
      targets[b['period'] as String] = money(amount);
      return _json({
        'id': 't-${b['period']}',
        'period': b['period'],
        'storeId': b['storeId'],
        'storeName': null,
        'amount': money(amount),
        'createdAt': '2026-11-18T00:00:00Z',
        'updatedAt': '2026-11-18T00:00:00Z',
      });
    }
    if (path == '/api/reports/employees') {
      final staff = employees.where((e) => e['deletedAt'] == null).toList();
      final active = staff.where((e) => e['status'] == 'ACTIVE');
      double sal(Iterable<Map<String, dynamic>> l) => l.fold(0.0, (a, e) => a + double.parse('${e['monthlySalary']}'));
      final positions = {for (final e in staff) e['position'] as String};
      return _json({
        'currency': 'TJS',
        'totalEmployees': staff.length,
        'activeEmployees': active.length,
        'inactiveEmployees': staff.length - active.length,
        'hiredThisMonth': 0,
        'monthlySalaryTotal': money(sal(active)),
        'averageMonthlySalary': money(active.isEmpty ? 0 : sal(active) / active.length),
        'byStore': [
          for (final s in stores.where((s) => s['deletedAt'] == null))
            {
              'storeId': s['id'],
              'storeName': s['name'],
              'storeStatus': s['status'],
              'storeIsDeleted': false,
              'employeesCount': staff.where((e) => e['storeId'] == s['id']).length,
              'activeEmployees': active.where((e) => e['storeId'] == s['id']).length,
              'monthlySalaryTotal': money(sal(active.where((e) => e['storeId'] == s['id']))),
            },
        ],
        'byPosition': [
          for (final p in positions)
            {
              'position': p,
              'employeesCount': staff.where((e) => e['position'] == p).length,
              'activeEmployees': active.where((e) => e['position'] == p).length,
              'monthlySalaryTotal': money(sal(active.where((e) => e['position'] == p))),
            },
        ],
      });
    }
    if (path == '/api/reports/payroll') {
      final y = int.tryParse(q['year'] ?? '') ?? today.year;
      final months = [
        for (var mo = 1; mo <= 12; mo++)
          if (y < today.year || mo <= today.month)
            () {
              final p = _monthlyPayroll(y, mo, null);
              return {
                'month': mo,
                'dueAmount': p['totalDue'],
                'paidAmount': p['totalPaid'],
                'remainingAmount': p['totalRemaining'],
                'employeesCount': p['employeesCount'],
                'paidCount': p['paidCount'],
              };
            }(),
      ];
      double sum(String k) => months.fold(0.0, (a, x) => a + double.parse('${x[k]}'));
      return _json({
        'currency': 'TJS',
        'year': y,
        'totalDue': money(sum('dueAmount')),
        'totalPaid': money(sum('paidAmount')),
        'totalRemaining': money(sum('remainingAmount')),
        'months': months,
      });
    }

    if (path == '/api/activity' && m == 'GET') {
      final storeId = q['storeId'];
      final rows = activity.where((a) => storeId == null || a['storeId'] == storeId).toList();
      final limit = int.tryParse(q['limit'] ?? '') ?? 20;
      return _json({'items': rows.take(limit).toList(), 'total': rows.length, 'page': 1, 'limit': limit, 'pages': 1});
    }

    // expenses + profit
    final expenseId = RegExp(r'^/api/expenses/([^/]+)$').firstMatch(path)?.group(1);
    Iterable<Map<String, dynamic>> liveExpenses() => expenses.where((e) => e['deleted'] != true);
    if (path == '/api/expenses' && m == 'GET') {
      final cat = q['category'];
      final rows = liveExpenses().where((e) => cat == null || e['category'] == cat).toList()
        ..sort((a, b) => '${b['expenseDate']}'.compareTo('${a['expenseDate']}'));
      final total = rows.fold<double>(0, (t, e) => t + double.parse(e['amount'] as String));
      return _json({
        'items': rows,
        'total': rows.length,
        'page': 1,
        'limit': 100,
        'pages': 1,
        'totalAmount': money(total),
      });
    }
    if ((path == '/api/expenses' && m == 'POST') || (expenseId != null && m == 'PUT')) {
      final b = body();
      final amount = double.tryParse('${b['amount']}') ?? 0;
      if (amount <= 0) return _error(422, 'VALIDATION_ERROR');
      final storeId = b['storeId'] as String?;
      if (storeId != null && _store(storeId) == null) return _error(404, 'STORE_NOT_FOUND');
      final existing = expenseId == null ? null : liveExpenses().where((e) => e['id'] == expenseId).firstOrNull;
      if (expenseId != null && existing == null) return _error(404, 'EXPENSE_NOT_FOUND');
      final row = existing ?? <String, dynamic>{'id': _id('x'), 'createdAt': DateTime.now().toUtc().toIso8601String()};
      row.addAll({
        'storeId': storeId,
        'storeName': storeId == null ? null : _store(storeId)!['name'],
        'category': b['category'],
        'amount': money(amount),
        'expenseDate': b['expenseDate'] ?? day(today),
        'description': b['description'],
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });
      if (existing == null) expenses.add(row);
      return _json(row, existing == null ? 201 : 200);
    }
    if (expenseId != null && m == 'DELETE') {
      final row = liveExpenses().where((e) => e['id'] == expenseId).firstOrNull;
      if (row == null) return _error(404, 'EXPENSE_NOT_FOUND');
      row['deleted'] = true;
      return http.Response('', 204);
    }
    if (path == '/api/reports/profit') {
      final start = DateTime(today.year, today.month);
      final end = DateTime(today.year, today.month + 1, 0);
      bool inMonth(String d) => !parseDay(d).isBefore(start) && !parseDay(d).isAfter(end);
      final salesTotal = _liveSales
          .where((x) => inMonth(x['saleDate'] as String))
          .fold<double>(0, (t, x) => t + double.parse(x['amount'] as String));
      final monthExpenses = liveExpenses().where((e) => inMonth(e['expenseDate'] as String)).toList();
      final expensesTotal = monthExpenses.fold<double>(0, (t, e) => t + double.parse(e['amount'] as String));
      final byCat = <String, double>{};
      for (final e in monthExpenses) {
        byCat[e['category'] as String] = (byCat[e['category']] ?? 0) + double.parse(e['amount'] as String);
      }
      const salaryDue = 0.0;
      final profit = salesTotal - expensesTotal - salaryDue;
      return _json({
        'currency': 'TJS',
        'period': {'startDate': day(start), 'endDate': day(end), 'days': end.day},
        'salesTotal': money(salesTotal),
        'expensesTotal': money(expensesTotal),
        'salaryDue': money(salaryDue),
        'grossProfit': money(profit),
        'marginPercent': salesTotal == 0 ? null : profit / salesTotal * 100,
        'byCategory': [
          for (final e in byCat.entries) {'category': e.key, 'totalAmount': money(e.value)},
        ],
        'byStore': <Object>[],
      });
    }

    if (path == '/api/notifications' && m == 'GET') {
      return _json({
        'items': notifications,
        'unreadCount': notifications.where((n) => n['read'] != true).length,
        'lastReadAt': null,
      });
    }
    if (path == '/api/notifications/read-all' && m == 'POST') {
      for (final n in notifications) {
        n['read'] = true;
      }
      return http.Response('', 204);
    }

    if (path == '/api/settings/exchange-rates') {
      return _json({
        'base': 'TJS',
        'rates': {'USD': usdRate},
        'updatedAt': '2026-11-18T00:00:00Z',
      });
    }

    if (path == '/api/assistant/chat' && m == 'POST') {
      final b = body();
      lastChatRequest = b;
      final messages = b['messages'];
      if (messages is! List || messages.isEmpty || !['en', 'ru', 'tg'].contains(b['language'])) {
        return _error(422, 'VALIDATION_ERROR');
      }
      if (assistantRateLimited) return _error(429, 'RATE_LIMITED');
      if (assistantReply == null) return _error(503, 'ASSISTANT_UNAVAILABLE');
      final proposed = nextActions;
      nextActions = [];
      for (final a in proposed) {
        actions[a['id'] as String] = a;
      }
      return _json({
        'role': 'assistant',
        'text': assistantReply,
        'time': DateTime.now().toUtc().toIso8601String(),
        'conversationId': '00000000-0000-0000-0000-000000000001',
        'actions': proposed,
      });
    }

    final actionMatch = RegExp(r'^/api/assistant/actions/([^/]+)(/confirm|/cancel)?$').firstMatch(path);
    if (actionMatch != null) {
      final a = actions[actionMatch.group(1)];
      if (a == null) return _error(404, 'ACTION_NOT_FOUND');
      final op = actionMatch.group(2);
      if (op == null && m == 'GET') return _json(a);
      if (a['status'] == 'PROPOSED' && DateTime.parse(a['expiresAt'] as String).isBefore(DateTime.now())) {
        a['status'] = 'EXPIRED';
        return _error(409, 'ACTION_EXPIRED');
      }
      if (op == '/cancel' && m == 'POST') {
        if (a['status'] == 'CANCELLED') return _json(a);
        if (a['status'] != 'PROPOSED') return _error(409, 'ACTION_ALREADY_HANDLED');
        a['status'] = 'CANCELLED';
        return _json(a);
      }
      if (op == '/confirm' && m == 'POST') {
        if (a['status'] == 'DONE') return _json(a);
        if (a['status'] != 'PROPOSED') return _error(409, 'ACTION_ALREADY_HANDLED');
        final params = {...a['params'] as Map<String, dynamic>, ...?(body()['params'] as Map<String, dynamic>?)};
        if (a['type'] == 'CREATE_STORE') {
          if (stores.any((s) => s['deletedAt'] == null && s['name'] == params['name'])) {
            a['status'] = 'FAILED';
            a['error'] = {'code': 'STORE_NAME_TAKEN', 'message': 'Taken.'};
            return _json(a);
          }
          final now = DateTime.now().toUtc().toIso8601String();
          final store = {
            'id': _id('s'),
            ...params,
            'status': params['status'] ?? 'ACTIVE',
            'createdAt': now,
            'updatedAt': now,
            'deletedAt': null,
          };
          stores.add(store);
          a['result'] = store;
        } else if (a['type'] == 'DELETE_STORE') {
          _store(params['id'] as String)?['deletedAt'] = DateTime.now().toUtc().toIso8601String();
        }
        a['status'] = 'DONE';
        return _json(a);
      }
    }

    return _error(404, 'NOT_FOUND');
  }
}

/// HTTP client that always fails (no internet).
class FakeBackendClientThatThrows extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => Future.error(Exception('offline'));
}
