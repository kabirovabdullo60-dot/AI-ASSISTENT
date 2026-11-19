import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/views/store_details_view.dart';
import 'package:subhon_app/widgets/store_strip_card.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('home shows the stores in a sideways strip with their month '
      'sales; no "Выручка за сегодня", no targets', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const id = '33333333-3333-3333-3333-333333333333';
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json('GET', '/api/stores/$id', ApiJson.store())
      ..json('GET', '/api/sales/store/$id', ApiJson.page([]))
      ..json('GET', '/api/employees/store/$id', ApiJson.page([]));
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await openBusiness(tester);

    expect(find.text('Магазины · 1'), findsOneWidget);
    expect(find.byType(StoreStripCard), findsOneWidget);
    expect(find.text('Добавить магазин'), findsOneWidget);
    expect(find.text('Выручка за сегодня'), findsNothing);
    expect(find.text('Цель на неделю'), findsNothing);
    expect(find.text('Цель на месяц'), findsNothing);
    expect(find.text('Прибыль за месяц'), findsOneWidget);
    // The strip scrolls sideways.
    final list = tester.widget<ListView>(
      find
          .ancestor(
            of: find.byType(StoreStripCard),
            matching: find.byType(ListView),
          )
          .first,
    );
    expect(list.scrollDirection, Axis.horizontal);

    await tester.tap(find.byType(StoreStripCard));
    await tester.pumpAndSettle();
    expect(find.byType(StoreDetailsView), findsOneWidget);
  });
}
