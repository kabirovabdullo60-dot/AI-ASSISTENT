import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/core/utils/format.dart';
import 'package:abdullo_web/main.dart';
import 'package:abdullo_web/widgets/page_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_backend.dart';

export 'fake_backend.dart';

const mobileWidth = 400.0;
const tabletWidth = 800.0;
const desktopWidth = 1400.0;

/// Fresh fake backend + browser storage for one test.
/// [signedIn] puts valid tokens in storage so the app opens on the dashboard.
FakeBackend setUpBackend({bool signedIn = true, String? language}) {
  setFormatLanguage('en');
  final backend = FakeBackend();
  final prefs = <String, Object>{'language': ?language};
  if (signedIn) {
    backend.accessToken = 'access-start';
    backend.refreshToken = 'refresh-start';
    prefs['accessToken'] = 'access-start';
    prefs['refreshToken'] = 'refresh-start';
  }
  SharedPreferences.setMockInitialValues(prefs);
  return backend;
}

/// Pumps the whole web at [width] against a fake backend and returns it.
Future<FakeBackend> pumpApp(
  WidgetTester tester,
  double width, {
  double height = 1000,
  bool signedIn = true,
  String? language,
  FakeBackend? backend,
}) async {
  final api = backend ?? setUpBackend(signedIn: signedIn, language: language);
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(WebApp(httpClient: api.client));
  await tester.pumpAndSettle();
  return api;
}

/// Opens a page the way a user would: sidebar, bottom bar, or "More" on a phone.
Future<void> openSection(WidgetTester tester, AppSection section) async {
  final bar = find.byType(NavigationBar);
  if (bar.evaluate().isEmpty) {
    await tester.tap(find.byKey(Key('nav-${section.name}')));
  } else if (AppSection.mobileBar.contains(section)) {
    final i = AppSection.mobileBar.indexOf(section);
    await tester.tap(find.descendant(of: bar, matching: find.byType(NavigationDestination)).at(i));
  } else {
    await tester.tap(find.descendant(of: bar, matching: find.byType(NavigationDestination)).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('more-${section.name}')));
  }
  await tester.pumpAndSettle();
}

/// Scrolls the page's main list until [finder] is on screen.
Future<void> scrollTo(WidgetTester tester, Finder finder, {double delta = 300}) async {
  final pageList = find.descendant(
    of: find.byType(PageBody),
    matching: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down),
  );
  await tester.scrollUntilVisible(finder, delta, scrollable: pageList.first);
  await tester.pumpAndSettle();
}

/// Scrolls the page back to the top.
Future<void> scrollToTop(WidgetTester tester) async {
  await tester.drag(find.byType(PageBody), const Offset(0, 5000));
  await tester.pumpAndSettle();
}
