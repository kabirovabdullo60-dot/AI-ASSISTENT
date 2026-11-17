import 'package:abdullo_web/models/chat_message_model.dart';
import 'package:abdullo_web/models/overview_model.dart';
import 'package:abdullo_web/models/payroll_model.dart';
import 'package:abdullo_web/services/assistant_service.dart';
import 'package:abdullo_web/services/dashboard_service.dart';
import 'package:abdullo_web/services/mock/mock_database.dart';
import 'package:abdullo_web/services/payroll_service.dart';
import 'package:abdullo_web/services/sales_service.dart';
import 'package:abdullo_web/services/store_service.dart';
import 'package:abdullo_web/viewmodels/assistant_view_model.dart';
import 'package:abdullo_web/viewmodels/dashboard_view_model.dart';
import 'package:abdullo_web/viewmodels/payroll_view_model.dart';
import 'package:abdullo_web/viewmodels/sales_view_model.dart';
import 'package:abdullo_web/viewmodels/stores_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

class _FailingDashboardService extends DashboardService {
  _FailingDashboardService() : super(useMock: true);

  @override
  Future<OverviewModel> fetchOverview({String? storeId}) async => throw Exception('offline');
}

void main() {
  setUp(resetDemoData);

  group('DashboardViewModel', () {
    test('load fills overview, chart and activity', () async {
      final vm = DashboardViewModel(DashboardService());
      await vm.load();
      expect(vm.error, isNull);
      expect(vm.overview!.todaySales, 36750);
      expect(vm.overview!.monthlySales, 1089500);
      expect(vm.overview!.unpaidSalaries, 7200);
      expect(vm.overview!.pendingPayrolls, 4);
      expect(vm.chartPoints, hasLength(24));
      expect(vm.chartPoints.last.revenue, 36750);
      expect(vm.activity(''), hasLength(4));
      vm.setRange(ChartRange.weekly);
      expect(vm.chartPoints, hasLength(7));
    });

    test('load error sets a message', () async {
      final vm = DashboardViewModel(_FailingDashboardService());
      await vm.load();
      expect(vm.overview, isNull);
      expect(vm.error, isNotNull);
    });
  });

  group('StoresViewModel', () {
    test('ranks, filters, sorts and groups by region', () async {
      final vm = StoresViewModel(StoreService());
      await vm.load();
      expect(vm.stores, hasLength(6));
      expect(vm.activeCount, 5);
      expect(vm.top(1).single.name, 'Central Plaza Flagship');
      expect((vm.shareOf(vm.top(1).single) * 100).round(), 31);
      expect(vm.visible('mall').single.name, 'Rudaki Mall Kiosk');
      vm.setStatusFilter(StoreStatusFilter.inactive);
      expect(vm.visible().single.name, 'Bokhtar Express Branch');
      vm.setStatusFilter(StoreStatusFilter.all);
      vm.setSort(StoreSort.name);
      expect(vm.visible().first.name, 'Bokhtar Express Branch');
      expect(vm.regions.first.region, 'Dushanbe');
      expect(vm.regions.first.stores, 4);
    });

    test('save + delete', () async {
      final vm = StoresViewModel(StoreService());
      await vm.load();
      final s = vm.byId('s2')!;
      expect(await vm.save(s.copyWith(phone: '+992 00 000 0000'), isNew: false), isTrue);
      expect(vm.byId('s2')!.phone, '+992 00 000 0000');
      expect(await vm.delete('s6'), isTrue);
      expect(vm.stores, hasLength(5));
    });
  });

  group('SalesViewModel', () {
    test('filters by range/store and saves entries', () async {
      final vm = SalesViewModel(SalesService());
      await vm.load();
      expect(vm.todayTotal, 36750);
      expect(vm.filtered(), hasLength(5));
      vm.setRange(SalesRange.month);
      expect(vm.filtered().length, greaterThan(5));
      vm.setStoreFilter('s3');
      expect(vm.filtered().every((s) => s.storeId == 's3'), isTrue);
      vm.setStoreFilter(null);

      expect(await vm.recordSale(storeId: 's1', amount: 0), isFalse);
      expect(await vm.recordSale(storeId: 's1', amount: 500, notes: 'Promo'), isTrue);
      expect(vm.lastSaved!.amount, 500);
      expect(vm.todayTotal, 37250);
      expect(MockDatabase.instance.store('s1')!.todaySales, 12900);
      expect(vm.storesSyncedToday, 5);
    });
  });

  group('PayrollViewModel', () {
    test('totals, tabs, payments, months', () async {
      final vm = PayrollViewModel(PayrollService());
      await vm.load();
      expect(vm.items, hasLength(14));
      expect(vm.pendingTotal, 7200);
      expect(vm.countFor(PayrollTab.partial), 2);
      expect(vm.countFor(PayrollTab.unpaid), 2);

      expect(await vm.recordPayment('p3', 1000), isTrue);
      expect(vm.byId('p3')!.status, PayStatus.paid);
      expect(vm.pendingTotal, 6200);
      expect(vm.historyFor('p3'), hasLength(2));

      await vm.previousMonth();
      expect(vm.isCurrentMonth, isFalse);
      expect(vm.pendingTotal, 0);
    });
  });

  test('AssistantViewModel: question + reply, clear', () async {
    final vm = AssistantViewModel(AssistantService());
    await vm.send('unpaid salaries?');
    expect(vm.messages, hasLength(2));
    expect(vm.messages.first.role, ChatRole.user);
    expect(vm.messages.last.text, contains('7,200'));
    vm.clear();
    expect(vm.messages, isEmpty);
  });

  test('mock replies understand Tajik and Russian', () {
    final db = MockDatabase.instance;
    expect(AssistantService.mockReply('Savdoi man chī tavr?', db), contains('36,750'));
    expect(AssistantService.mockReply('Какие лучшие магазины?', db), contains('Central Plaza Flagship'));
  });

  test('models read backend JSON with {data: ...} wrappers', () {
    final o = OverviewModel.fromJson({
      'todaySales': 100,
      'dailyRevenue': {
        'data': [
          {'date': '2026-11-01', 'revenue': 5, 'cashflow': 2},
        ],
      },
    });
    expect(o.todaySales, 100);
    expect(o.dailyRevenue.single.revenue, 5);
    final p = PayrollModel.fromJson({'salary': 2800, 'disbursed': 1800});
    expect(p.status, PayStatus.partial);
    expect(p.remaining, 1000);
  });
}
