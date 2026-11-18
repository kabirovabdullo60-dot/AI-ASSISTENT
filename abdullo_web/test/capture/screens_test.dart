// Saves PNG screenshots of every page (real Roboto font + icons) for design review.
// Run: flutter test test/capture/screens_test.dart --dart-define=CAPTURE=true --dart-define=OUT=<dir>
import 'dart:io';
import 'dart:ui' as ui;

import 'package:abdullo_web/core/navigation/app_section.dart';
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
const _fonts = '/Users/abdullo/Documents/flutter/bin/cache/artifacts/material_fonts';

Future<void> _loadFonts() async {
  ByteData f(String path) => ByteData.sublistView(File(path).readAsBytesSync());
  await (FontLoader('Onest')..addFont(Future.value(f('assets/fonts/Onest.ttf')))).load();
  await (FontLoader('MaterialIcons')..addFont(Future.value(f('$_fonts/MaterialIcons-Regular.otf')))).load();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('capture-root')));
  await tester.runAsync(() async {
    final ui.Image img = await boundary.toImage(pixelRatio: 1);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    await Directory(_out).create(recursive: true);
    await File('$_out/$_paletteName-$name.png').writeAsBytes(bytes!.buffer.asUint8List());
  });
}

Map<String, dynamic> _expense(String id, String cat, String amount, String desc) => {
  'id': id, 'storeId': null, 'storeName': null, 'category': cat, 'amount': amount,
  'expenseDate': FakeBackend.day(DateTime.now()), 'description': desc,
  'createdAt': '2026-11-18T08:00:00Z', 'updatedAt': '2026-11-18T08:00:00Z',
};

void main() {
  setUpAll(() async {
    if (_capture) await _loadFonts();
  });
  setUp(() => AppColors.use(AppPalette.fromName(_paletteName)));

  for (final (label, size) in [('desktop', const Size(1440, 1000)), ('mobile', const Size(400, 860))]) {
    testWidgets('capture $label', (tester) async {
      final backend = setUpBackend(signedIn: false)
        ..assistantReply = 'This month you sold 1,500 TJS in 2 sales. Central Plaza sold the most (1,000 TJS). '
            'Salaries still to pay: 4,200 TJS — open Salaries to pay them.'
        ..targets.addAll({'WEEK': '3000.00', 'MONTH': '12000.00'})
        ..expenses.addAll([
          _expense('x1', 'RENT', '2500.00', 'November rent'),
          _expense('x2', 'DELIVERY', '320.00', 'Courier'),
        ])
        ..notifications.add({
          'id': 'n1', 'kind': 'SALARY_OVERDUE', 'severity': 'WARNING', 'count': 2, 'amount': '4200.00',
          'storeId': null, 'storeName': null, 'link': 'PAYROLL', 'read': false, 'createdAt': '2026-11-01T00:00:00Z',
        });
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(RepaintBoundary(key: const Key('capture-root'), child: WebApp(httpClient: backend.client)));
      await _shot(tester, '$label-0-login');

      await tester.enterText(find.byKey(const Key('login-email')), 'owner@test.tj');
      await tester.enterText(find.byKey(const Key('login-password')), FakeBackend.password);
      await tester.tap(find.byKey(const Key('login-submit')));
      await _shot(tester, '$label-1-dashboard');

      var i = 2;
      for (final s in [AppSection.stores, AppSection.sales, AppSection.salaries, AppSection.expenses, AppSection.reports]) {
        await openSection(tester, s);
        await _shot(tester, '$label-${i++}-${s.name}');
      }
      await openSection(tester, AppSection.assistant);
      await _shot(tester, '$label-${i++}-assistant-empty');
      await tester.enterText(find.byKey(const Key('chat-input')), 'How are my sales this month?');
      await tester.tap(find.byKey(const Key('chat-send')));
      await _shot(tester, '$label-${i++}-assistant-chat');
    }, skip: !_capture);
  }

  testWidgets('capture assistant in tg', (tester) async {
    final backend = setUpBackend(language: 'tg');
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RepaintBoundary(key: const Key('capture-root'), child: WebApp(httpClient: backend.client)));
    await tester.pumpAndSettle();
    await openSection(tester, AppSection.assistant);
    await _shot(tester, 'tg-assistant-empty');
  }, skip: !_capture);
}
