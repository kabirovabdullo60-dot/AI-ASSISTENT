import 'package:abdullo_web/main.dart';
import 'package:abdullo_web/services/assistant_service.dart';
import 'package:abdullo_web/services/dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const mobileWidth = 400.0;
const tabletWidth = 800.0;
const desktopWidth = 1400.0;

/// Pumps the whole web at [width] with instant demo services.
Future<void> pumpAt(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    WebApp(
      dashboardService: DashboardService(useMock: true, mockDelay: Duration.zero),
      assistantService: AssistantService(useMock: true, mockDelay: Duration.zero),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens a section by its label (works for bottom bar and rail).
Future<void> openSection(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}
