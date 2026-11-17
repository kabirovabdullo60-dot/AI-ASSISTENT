import 'package:abdullo_web/models/chat_message_model.dart';
import 'package:abdullo_web/services/assistant_service.dart';
import 'package:abdullo_web/services/dashboard_service.dart';
import 'package:abdullo_web/viewmodels/assistant_view_model.dart';
import 'package:abdullo_web/viewmodels/dashboard_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingDashboardService extends DashboardService {
  _FailingDashboardService() : super(useMock: true);

  @override
  Future<Never> fetchDashboard() async => throw Exception('offline');
}

void main() {
  group('DashboardViewModel', () {
    test('load fills data and report numbers', () async {
      final vm = DashboardViewModel(DashboardService(useMock: true, mockDelay: Duration.zero));
      await vm.load();
      expect(vm.error, isNull);
      expect(vm.data!.kpis, hasLength(4));
      expect(vm.totalSales, 232450);
      expect(vm.averageSales.round(), 38742);
      expect(vm.bestMonth!.label, 'Nov');
      expect(vm.changeAt(0), isNull);
      expect(vm.changeAt(5)!.toStringAsFixed(1), '12.2');
    });

    test('load error sets a message', () async {
      final vm = DashboardViewModel(_FailingDashboardService());
      await vm.load();
      expect(vm.data, isNull);
      expect(vm.error, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });

  group('AssistantViewModel', () {
    test('send adds question and reply, ignores empty text', () async {
      final vm = AssistantViewModel(AssistantService(useMock: true, mockDelay: Duration.zero));
      await vm.send('   ');
      expect(vm.messages, isEmpty);

      await vm.send('expenses?');
      expect(vm.messages, hasLength(2));
      expect(vm.messages.first.role, ChatRole.user);
      expect(vm.messages.last.text, contains('31,780'));

      vm.clear();
      expect(vm.messages, isEmpty);
    });
  });

  test('mock replies understand Tajik and Russian', () {
    expect(AssistantService.mockReply('Savdoi man chī tavr?'), contains('48,250'));
    expect(AssistantService.mockReply('Какая прибыль?'), contains('16,470'));
  });
}
