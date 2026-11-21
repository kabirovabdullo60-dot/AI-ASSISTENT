import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:subhon_app/core/network/api_client.dart';
import 'package:subhon_app/core/theme/app_theme.dart';
import 'package:subhon_app/l10n/l10n.dart';
import 'package:subhon_app/services/activity_service.dart';
import 'package:subhon_app/services/reports_service.dart';
import 'package:subhon_app/viewmodels/history_view_model.dart';
import 'package:subhon_app/views/history_view.dart';

import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

Map<String, Object?> _op(String createdAt, {String name = 'Бахор — Сомони'}) =>
    {
      ...ApiJson.activity(entityName: name),
      'storeName': name,
      'createdAt': createdAt,
    };

Future<FakeBackend> _pump(WidgetTester tester) async {
  await initializeDateFormatting();
  await tester.binding.setSurfaceSize(const Size(800, 2000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final backend = FakeBackend()
    ..json('GET', '/api/reports/profit', ApiJson.profit())
    ..json(
      'GET',
      '/api/activity',
      ApiJson.page([
        _op('2026-11-18T09:05:00Z'),
        _op('2026-11-18T07:00:00Z', name: 'Бахор — Худжанд'),
        _op('2026-11-16T12:00:00Z'),
      ]),
    );
  final api = ApiClient(
    tokens: MemoryTokenStorage(accessToken: 'a'),
    client: backend.client,
  );
  final vm = HistoryViewModel(
    ActivityService(api),
    ReportsService(api),
    clock: () => DateTime(2026, 11, 19, 12),
  )..load();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('ru'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: ChangeNotifierProvider.value(value: vm, child: const HistoryView()),
    ),
  );
  await tester.pumpAndSettle();
  return backend;
}

void main() {
  testWidgets('expenses of the month, statement, operations by day', (
    tester,
  ) async {
    await _pump(tester);
    expect(find.text('Расходы за ноябрь'), findsOneWidget);
    expect(find.textContaining('12 000'), findsOneWidget);
    expect(find.text('Выписка'), findsOneWidget);
    // Two days, newest first, with the weekday.
    expect(find.text('18 ноября, среда'), findsOneWidget);
    expect(find.text('16 ноября, понедельник'), findsOneWidget);
    expect(find.text('Бахор — Худжанд'), findsOneWidget);
    expect(find.text('Продажа'), findsNWidgets(3));
  });

  testWidgets('"Вчера" and "Неделя" ask for those days', (tester) async {
    final backend = await _pump(tester);
    await tester.tap(find.text('Вчера'));
    await tester.pumpAndSettle();
    var q = backend.calls('GET', '/api/activity').last.url.queryParameters;
    expect((q['startDate'], q['endDate']), ('2026-11-18', '2026-11-18'));
    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();
    q = backend.calls('GET', '/api/activity').last.url.queryParameters;
    expect((q['startDate'], q['endDate']), ('2026-11-13', '2026-11-19'));
    await tester.tap(find.text('Все'));
    await tester.pumpAndSettle();
    q = backend.calls('GET', '/api/activity').last.url.queryParameters;
    expect(q.containsKey('startDate'), isFalse);
  });

  testWidgets('the eye hides the amount; search filters by name', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.byTooltip('Скрыть сумму'));
    await tester.pumpAndSettle();
    expect(find.text('••••• TJS'), findsOneWidget);

    await tester.tap(find.byTooltip('Поиск'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'худжанд');
    await tester.pumpAndSettle();
    expect(find.text('Бахор — Худжанд'), findsOneWidget);
    expect(find.text('Бахор — Сомони'), findsNothing);
  });
}
