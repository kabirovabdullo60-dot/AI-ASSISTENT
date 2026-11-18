import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/widgets/accounting_item_kind.dart';
import 'package:subhon_app/widgets/accounting_rain.dart';
import 'package:subhon_app/widgets/accounting_rain_drop.dart';
import 'package:subhon_app/widgets/accounting_rain_painter.dart';

AccountingRainPainter _painter(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(
              find.descendant(
                of: find.byType(AccountingRain),
                matching: find.byType(CustomPaint),
              ),
            )
            .painter!
        as AccountingRainPainter;

Widget _host({bool still = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: still),
  child: const Directionality(
    textDirection: TextDirection.ltr,
    child: AccountingRain(),
  ),
);

void main() {
  test('every kind of item falls, far ones painted first', () {
    final drops = AccountingRainDrop.generate();
    expect(drops.map((d) => d.kind).toSet(), AccountingItemKind.values.toSet());
    for (var i = 1; i < drops.length; i++) {
      expect(drops[i].depth, greaterThanOrEqualTo(drops[i - 1].depth));
    }
    // The same rain on every start.
    expect(AccountingRainDrop.generate().first.x, drops.first.x);
  });

  testWidgets('the items keep falling and every kind paints', (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump(const Duration(seconds: 2));
    expect(_painter(tester).time.value, greaterThan(1.9));
    expect(tester.takeException(), isNull);
  });

  testWidgets('with reduce motion they stand still', (tester) async {
    await tester.pumpWidget(_host(still: true));
    await tester.pump(const Duration(seconds: 2));
    expect(_painter(tester).time.value, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
