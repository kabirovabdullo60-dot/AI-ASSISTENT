import 'package:abdullo_web/models/chat_message_model.dart';
import 'package:abdullo_web/models/overview_model.dart';
import 'package:abdullo_web/models/sale_model.dart';
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
      expect(vm.overview!.todaySales, 38450);
      expect(vm.overview!.unpaidSalaries, 14200);
      expect(vm.chartPoints, hasLength(24));
      expect(vm.chartPoints[vm.peakIndex].revenue, 52100);
      expect(vm.activity(''), hasLength(4));
      expect(vm.activity('payroll'), hasLength(1));

      vm.setRange(ChartRange.weekly);
      expect(vm.chartPoints, hasLength(7));
    });

    test('load error sets a message', () async {
      final vm = DashboardViewModel(_FailingDashboardService());
      await vm.load();
      expect(vm.overview, isNull);
      expect(vm.error, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });

  test('StoresViewModel ranks stores and computes share', () async {
    final vm = StoresViewModel(StoreService());
    await vm.load();
    expect(vm.top(1).single.name, 'Central Plaza Store');
    expect((vm.shareOf(vm.top(1).single) * 100).round(), 31);
    expect(vm.filtered('mall'), hasLength(1));
  });

  test('SalesViewModel.recordSale saves and rejects 0', () async {
    final vm = SalesViewModel(SalesService());
    await vm.load();
    expect(await vm.recordSale(storeId: 's1', amount: 0, method: PaymentMethod.cash), isFalse);
    expect(await vm.recordSale(storeId: 's1', amount: 500, method: PaymentMethod.qr), isTrue);
    expect(vm.sales.first.amount, 500);
    expect(MockDatabase.instance.overview().todaySales, 38950);
  });

  test('PayrollViewModel.markPaid lowers the unpaid total', () async {
    final vm = PayrollViewModel(PayrollService());
    await vm.load();
    expect(vm.pendingTotal, 14200);
    expect(await vm.markPaid('p1'), isTrue);
    expect(vm.pendingTotal, 10400);
    expect(vm.pendingCount, 3);
  });

  test('AssistantViewModel: question + reply, clear', () async {
    final vm = AssistantViewModel(AssistantService());
    await vm.send('   ');
    expect(vm.messages, isEmpty);
    await vm.send('unpaid salaries?');
    expect(vm.messages, hasLength(2));
    expect(vm.messages.first.role, ChatRole.user);
    expect(vm.messages.last.text, contains('14,200'));
    vm.clear();
    expect(vm.messages, isEmpty);
  });

  test('mock replies understand Tajik and Russian', () {
    final db = MockDatabase.instance;
    expect(AssistantService.mockReply('Savdoi man chī tavr?', db), contains('38,450'));
    expect(AssistantService.mockReply('Какие лучшие магазины?', db), contains('Central Plaza Store'));
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
  });
}
