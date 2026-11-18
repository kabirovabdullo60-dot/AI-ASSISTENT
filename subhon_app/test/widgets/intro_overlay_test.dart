import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/widgets/drip_painter.dart';
import 'package:subhon_app/widgets/intro_eyes.dart';
import 'package:subhon_app/widgets/intro_overlay.dart';

Widget _host({bool reduceMotion = false}) => MediaQuery(
  data: MediaQueryData(disableAnimations: reduceMotion),
  child: const Directionality(
    textDirection: TextDirection.ltr,
    child: IntroOverlay(child: Text('app')),
  ),
);

void main() {
  testWidgets('plays over the app, eyes look sideways, then goes away', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    expect(find.text('app'), findsOneWidget);
    expect(find.byType(IntroEyes), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    final eyes = tester.widget<IntroEyes>(find.byType(IntroEyes));
    expect(eyes.look, lessThan(-0.5)); // looking left
    expect(eyes.openness, greaterThan(0.9));

    await tester.pump(const Duration(milliseconds: 600)); // 1.4 s
    expect(
      tester.widget<IntroEyes>(find.byType(IntroEyes)).look,
      greaterThan(0.5), // looking right
    );

    await tester.pumpAndSettle();
    expect(find.byType(IntroEyes), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is DripPainter,
      ),
      findsNothing,
    );
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('is skipped when reduce motion is on', (tester) async {
    await tester.pumpWidget(_host(reduceMotion: true));
    expect(find.byType(IntroEyes), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });
}
