import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/main.dart';
import 'package:abdullo_web/services/base_service.dart';
import 'package:abdullo_web/services/mock/mock_database.dart';
import 'package:abdullo_web/widgets/page_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const mobileWidth = 400.0;
const tabletWidth = 800.0;
const desktopWidth = 1400.0;

/// Instant demo data, fresh for every test.
void resetDemoData() {
  BaseService.mockDelay = Duration.zero;
  MockDatabase.instance.reset();
}

/// Pumps the whole web at [width] x [height].
Future<void> pumpAt(WidgetTester tester, double width, {double height = 1000}) async {
  resetDemoData();
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const WebApp());
  await tester.pumpAndSettle();
}

/// Opens a page the way a user would: sidebar, bottom bar, or "More" on a phone.
Future<void> openSection(WidgetTester tester, AppSection section) async {
  final bar = find.byType(NavigationBar);
  if (bar.evaluate().isEmpty) {
    await tester.tap(find.byKey(Key('nav-${section.name}')));
  } else if (AppSection.mobileBar.contains(section)) {
    await tester.tap(find.descendant(of: bar, matching: find.text(section.label)));
  } else {
    await tester.tap(find.descendant(of: bar, matching: find.text('More')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('more-${section.name}')));
  }
  await tester.pumpAndSettle();
}

/// Scrolls the page's main list until [finder] is on screen.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  final pageList = find.descendant(
    of: find.byType(PageBody),
    matching: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down),
  );
  await tester.scrollUntilVisible(finder, 300, scrollable: pageList.first);
  await tester.pumpAndSettle();
}
