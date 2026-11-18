import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/widgets/jelly_blob.dart';
import 'package:subhon_app/widgets/jelly_blob_painter.dart';

JellyBlobPainter _painter(WidgetTester tester) =>
    tester
            .widget<CustomPaint>(
              find.descendant(
                of: find.byType(JellyBlob),
                matching: find.byType(CustomPaint),
              ),
            )
            .painter!
        as JellyBlobPainter;

Widget _host(ValueNotifier<Offset?> lookAt, {bool closed = false}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: JellyBlob(lookAt: lookAt, eyesClosed: closed),
      ),
    );

void main() {
  testWidgets('the eyes glide toward the finger', (tester) async {
    final lookAt = ValueNotifier<Offset?>(null);
    addTearDown(lookAt.dispose);
    await tester.pumpWidget(_host(lookAt));
    final center = tester.getCenter(find.byType(JellyBlob));

    lookAt.value = center + const Offset(-300, 0); // far to the left
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(_painter(tester).pose.look.dx, lessThan(-0.9));

    lookAt.value = center + const Offset(0, 300); // below
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final look = _painter(tester).pose.look;
    expect(look.dy, greaterThan(0.9));
    expect(look.dx.abs(), lessThan(0.1));
  });

  testWidgets('closes its eyes on request', (tester) async {
    final lookAt = ValueNotifier<Offset?>(null);
    addTearDown(lookAt.dispose);
    await tester.pumpWidget(_host(lookAt, closed: true));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(_painter(tester).pose.openness, lessThan(0.05));
  });

  testWidgets('with reduce motion it does not animate but still looks', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final lookAt = ValueNotifier<Offset?>(null);
    addTearDown(lookAt.dispose);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _host(lookAt),
      ),
    );
    expect(tester.binding.hasScheduledFrame, isFalse);
    lookAt.value =
        tester.getCenter(find.byType(JellyBlob)) + const Offset(400, 0);
    await tester.pump();
    expect(_painter(tester).pose.look.dx, closeTo(1, 0.01));
  });

  testWidgets('with nothing to look at, the eyes look straight ahead', (
    tester,
  ) async {
    final lookAt = ValueNotifier<Offset?>(null);
    addTearDown(lookAt.dispose);
    await tester.pumpWidget(_host(lookAt));
    for (var i = 0; i < 300; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(_painter(tester).pose.look, Offset.zero);
    }
  });
}
