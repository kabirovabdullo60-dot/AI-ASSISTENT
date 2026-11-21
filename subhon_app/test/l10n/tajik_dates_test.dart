import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/l10n/l10n.dart';
import 'package:subhon_app/l10n/tajik_dates.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  test('Tajik dates are made by hand (intl has no tg data)', () {
    final d = DateTime(2026, 11, 16, 9, 5); // a Monday
    expect(TajikDates.date(d), '16 ноябри 2026');
    expect(TajikDates.shortDate(d), '16.11.2026');
    expect(TajikDates.dateTime(d), '16.11.2026, 09:05');
    expect(TajikDates.dayHeader(d), '16 ноябри, душанбе');
    expect(TajikDates.month(1), 'январ');
    expect(TajikDates.monthYear(5, 2026), 'Майи 2026');
    expect(TajikDates.dayHeader(DateTime(2026, 11, 20)), '20 ноябри, ҷумъа');
  });

  testWidgets('every date helper works in Tajik without Russian month names', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile());
    stubHome(backend);
    await pumpApp(
      tester,
      backend,
      locale: const Locale('tg'),
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    final context = tester.element(find.byType(Scaffold).first);
    final d = DateTime(2026, 11, 16, 14, 30);
    final texts = [
      context.formatDate(d),
      context.formatShortDate(d),
      context.formatDateTime(d),
      context.formatDayHeader(d),
      context.monthName(d),
      context.monthYear(11, 2026),
    ];
    expect(texts, [
      '16 ноябри 2026',
      '16.11.2026',
      '16.11.2026, 14:30',
      '16 ноябри, душанбе',
      'ноябр',
      'Ноябри 2026',
    ]);
    for (final t in texts) {
      expect(t, isNot(contains('ноября')));
      expect(t, isNot(contains('понедельник')));
    }
  });
}
