// Screenshots of the splash and login with the real photos (run with --dart-define=CAPTURE=true).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:abdullo_web/core/theme/app_colors.dart';
import 'package:abdullo_web/core/theme/app_palette.dart';
import 'package:abdullo_web/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const _capture = bool.fromEnvironment('CAPTURE');
const _out = String.fromEnvironment('OUT', defaultValue: 'build/screens');
const _paletteName = String.fromEnvironment('PALETTE', defaultValue: 'aurora');
const _photos = [
  'assets/images/money_stack.jpg',
  'assets/images/cosmetics_shop.jpg',
  'assets/images/money_hand.jpg',
  'assets/images/shop_counter.jpg',
];

Future<void> _shot(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('capture-root')));
  await tester.runAsync(() async {
    final img = await boundary.toImage();
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    await Directory(_out).create(recursive: true);
    await File('$_out/$_paletteName-$name.png').writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Future<void> _precache(WidgetTester tester) async {
  final ctx = tester.element(find.byType(MaterialApp).first);
  await tester.runAsync(() async {
    for (final p in _photos) {
      await precacheImage(AssetImage(p), ctx);
    }
  });
  await tester.pump();
}

void main() {
  setUpAll(() async {
    if (!_capture) return;
    ByteData f(String path) => ByteData.sublistView(File(path).readAsBytesSync());
    await (FontLoader('Onest')..addFont(Future.value(f('assets/fonts/Onest.ttf')))).load();
    await (FontLoader('Raleway')..addFont(Future.value(f('assets/fonts/Raleway.ttf')))).load();
    await (FontLoader('MaterialIcons')..addFont(Future.value(f('/Users/abdullo/Documents/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf')))).load();
  });
  setUp(() => AppColors.use(AppPalette.fromName(_paletteName)));

  for (final (label, size) in [('desktop', const Size(1440, 900)), ('mobile', const Size(400, 860))]) {
    testWidgets('capture splash + login $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // Signed in + slow server → the splash stays up while the session is checked.
      final backend = setUpBackend()..latency = const Duration(seconds: 3);
      await tester.pumpWidget(RepaintBoundary(key: const Key('capture-root'), child: WebApp(httpClient: backend.client)));
      await _precache(tester);
      await tester.pump(const Duration(milliseconds: 1400));
      await _shot(tester, '$label-splash');
      await tester.pumpAndSettle();
    }, skip: !_capture);

    testWidgets('capture login $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final backend2 = setUpBackend(signedIn: false);
      await tester.pumpWidget(RepaintBoundary(key: const Key('capture-root'), child: WebApp(httpClient: backend2.client)));
      await _precache(tester);
      await tester.pump(const Duration(milliseconds: 2500));
      await _shot(tester, '$label-login');
      await tester.pumpAndSettle();
    }, skip: !_capture);
  }
}
