import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/widgets/jelly_blob.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';

ValueNotifier<Offset?> _lookAt(WidgetTester tester) =>
    tester.widget<JellyBlob>(find.byType(JellyBlob)).lookAt
        as ValueNotifier<Offset?>;

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('a touch: look there, then look around again', (tester) async {
    await pumpApp(tester, FakeBackend());
    const spot = Offset(40, 500);
    final gesture = await tester.startGesture(spot);
    await tester.pump();
    expect(_lookAt(tester).value, spot);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 500));
    expect(_lookAt(tester).value, spot); // still looking for a moment
    await tester.pump(const Duration(milliseconds: 800));
    expect(_lookAt(tester).value, isNull); // back to glancing around
  });

  testWidgets('moving the mouse without a click does nothing', (tester) async {
    await pumpApp(tester, FakeBackend());
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: const Offset(10, 10));
    await mouse.moveTo(const Offset(300, 500));
    await tester.pump();
    expect(_lookAt(tester).value, isNull);
  });
}
