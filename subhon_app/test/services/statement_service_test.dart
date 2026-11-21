import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:subhon_app/core/network/api_client.dart';
import 'package:subhon_app/l10n/generated/app_localizations_ru.dart';
import 'package:subhon_app/l10n/statement_excel.dart';
import 'package:subhon_app/models/statement_kind.dart';
import 'package:subhon_app/models/statement_total_kind.dart';
import 'package:subhon_app/services/activity_service.dart';
import 'package:subhon_app/services/expense_service.dart';
import 'package:subhon_app/services/payroll_service.dart';
import 'package:subhon_app/services/reports_service.dart';
import 'package:subhon_app/services/sales_service.dart';
import 'package:subhon_app/services/statement_service.dart';

import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

Map<String, Object?> _sale(
  String id,
  String amount, {
  String? method,
  String? cash,
  String? card,
}) => {
  ...ApiJson.sale(id: id, amount: amount),
  'paymentMethod': method,
  'cashAmount': cash,
  'cardAmount': card,
};

StatementService _service(FakeBackend backend) {
  final api = ApiClient(
    tokens: MemoryTokenStorage(accessToken: 'a'),
    client: backend.client,
  );
  return StatementService(
    SalesService(api),
    ExpenseService(api),
    PayrollService(api),
    ActivityService(api),
    ReportsService(api),
  );
}

double _total(dynamic s, StatementTotalKind kind) =>
    (s.totals as List<(StatementTotalKind, double)>)
        .firstWhere((t) => t.$1 == kind)
        .$2;

void main() {
  setUpAll(initializeDateFormatting);

  final sales = [
    _sale('44444444-4444-4444-4444-000000000001', '100.00', method: 'CASH'),
    _sale('44444444-4444-4444-4444-000000000002', '200.00', method: 'CARD'),
    _sale(
      '44444444-4444-4444-4444-000000000003',
      '300.00',
      method: 'MIXED',
      cash: '120.00',
      card: '180.00',
    ),
    _sale('44444444-4444-4444-4444-000000000004', '50.00', method: 'QR'),
    _sale('44444444-4444-4444-4444-000000000005', '30.00'),
  ];

  FakeBackend backendWithSales() {
    // Two pages: the service must read both.
    return FakeBackend()..on('GET', '/api/sales', (request) {
      final page = int.parse(request.url.queryParameters['page']!);
      return FakeBackend.respond(
        ApiJson.page(
          page == 1 ? sales.sublist(0, 3) : sales.sublist(3),
          page: page,
          pages: 2,
        ),
      );
    });
  }

  test('sales: every page, totals by payment method', () async {
    final backend = backendWithSales();
    final s = await _service(backend).build(
      StatementKind.sales,
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 11, 19),
    );
    expect(backend.calls('GET', '/api/sales'), hasLength(2));
    expect(
      backend.calls('GET', '/api/sales').first.url.queryParameters['startDate'],
      '2026-11-01',
    );
    expect(s.rows, hasLength(5));
    expect(_total(s, StatementTotalKind.total), 680);
    expect(_total(s, StatementTotalKind.cash), 220); // 100 + 120 of mixed
    expect(_total(s, StatementTotalKind.card), 380); // 200 + 180 of mixed
    expect(_total(s, StatementTotalKind.qr), 50);
    expect(_total(s, StatementTotalKind.noMethod), 30);
  });

  test('cash only: cash sales and the cash part of mixed ones', () async {
    final s = await _service(backendWithSales()).build(StatementKind.cash);
    expect(s.rows.map((r) => r.amount), [100, 120]);
    expect(_total(s, StatementTotalKind.cash), 220);
  });

  test('card and QR only: no cash, mixed split', () async {
    final s = await _service(backendWithSales()).build(StatementKind.card);
    expect(s.rows.map((r) => r.amount), [200, 180, 50]);
    expect(_total(s, StatementTotalKind.total), 430);
  });

  test('who is owed salary: only employees with something left', () async {
    final backend = FakeBackend()
      ..json('GET', '/api/payroll/summary', {
        'currency': 'TJS',
        'asOf': '2026-11-19',
        'employeesCount': 2,
        'totalDue': '9000.00',
        'totalPaid': '6000.00',
        'totalRemaining': '3000.00',
        'currentMonth': {
          'year': 2026,
          'month': 11,
          'dueAmount': '6000.00',
          'paidAmount': '3000.00',
          'remainingAmount': '3000.00',
        },
        'items': [
          for (final (name, left) in [
            ('Шерзод', '3000.00'),
            ('Нигина', '0.00'),
          ])
            {
              'employeeId': '55555555-5555-5555-5555-55555555555${name.length}',
              'fullName': name,
              'position': 'Продавец',
              'storeId': '33333333-3333-3333-3333-333333333333',
              'storeName': 'Бахор — Сомони',
              'employeeStatus': 'ACTIVE',
              'isDeleted': false,
              'hiredAt': '2026-01-01',
              'terminatedAt': null,
              'monthsWorked': 10,
              'monthlySalary': '3000.00',
              'totalDue': '4500.00',
              'totalPaid': '4500.00',
              'totalRemaining': left,
              'unpaidMonths': left == '0.00' ? 0 : 1,
            },
        ],
      });
    final s = await _service(backend).build(StatementKind.salaryDebt);
    expect(s.rows.single.title, 'Шерзод');
    expect(_total(s, StatementTotalKind.remaining), 3000);
  });

  test('the Excel file has the headers, real numbers and the totals', () async {
    final s = await _service(backendWithSales()).build(
      StatementKind.cash,
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 11, 19),
    );
    final bytes = statementToExcel(s, AppLocalizationsRu());
    final book = Excel.decodeBytes(bytes);
    final sheet = book.tables[book.tables.keys.first]!;
    final text = [
      for (final row in sheet.rows)
        for (final c in row) c?.value?.toString() ?? '',
    ];
    expect(text, contains('Наличные'));
    expect(text, contains('Дата'));
    expect(text, contains('Сумма, TJS'));
    expect(text, contains('120'));
    expect(text.where((t) => t == '220'), hasLength(1));
  });
}
