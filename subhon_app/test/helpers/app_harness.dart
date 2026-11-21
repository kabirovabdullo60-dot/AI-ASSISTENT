import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/storage/app_lock_storage.dart';
import 'package:subhon_app/core/storage/chat_history_storage.dart';
import 'package:subhon_app/core/storage/debt_storage.dart';
import 'package:subhon_app/core/storage/personal_finance_storage.dart';

import 'package:subhon_app/services/file_pick_service.dart';
import 'package:subhon_app/services/reminder_service.dart';

import 'fake_file_pick_service.dart';
import 'memory_chat_history_storage.dart';
import 'fake_reminder_service.dart';
import 'memory_personal_finance_storage.dart';
import 'package:subhon_app/core/storage/statement_history_storage.dart';
import 'package:subhon_app/main.dart';
import 'package:subhon_app/services/biometric_service.dart';
import 'package:subhon_app/services/market_service.dart';
import 'package:subhon_app/services/file_share_service.dart';
import 'package:subhon_app/services/voice_service.dart';

import 'fake_backend.dart';
import 'memory_locale_storage.dart';
import 'memory_token_storage.dart';

/// Routes a signed-in user's first screens need.
void stubHome(FakeBackend backend) {
  backend
    ..json('GET', '/api/reports/dashboard', ApiJson.dashboard())
    ..json('GET', '/api/sales/daily', ApiJson.salesReport())
    ..json('GET', '/api/reports/store-comparison', ApiJson.storeComparison())
    ..json('GET', '/api/stores', ApiJson.page([ApiJson.store()]))
    ..json(
      'GET',
      '/api/sales',
      ApiJson.page([ApiJson.sale()], totalAmount: '1250.50'),
    )
    ..json('GET', '/api/payroll/monthly', ApiJson.monthlyPayroll());
}

/// Turns on "reduce motion" for this test: the launch intro is skipped and
/// the login mascot stands still, so `pumpAndSettle` can settle.
void reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

/// The whole app against [backend], in [locale].
Future<void> pumpApp(
  WidgetTester tester,
  FakeBackend backend, {
  MemoryTokenStorage? tokens,
  Locale locale = const Locale('ru'),
  VoiceService? voice,
  ChatHistoryStorage? chatHistory,
  StatementHistoryStorage? statementHistory,
  FileShareService? fileShare,
  BiometricService? biometric,
  AppLockStorage? appLock,
  MarketService? market,
  DebtStorage? debts,
  PersonalFinanceStorage? personal,
  ReminderService? reminders,
  FilePickService? filePick,
}) async {
  reduceMotion(tester);
  await tester.pumpWidget(
    MobileApp(
      httpClient: backend.client,
      tokens: tokens ?? MemoryTokenStorage(),
      localeStorage: MemoryLocaleStorage(),
      locale: locale,
      voice: voice,
      chatHistory: chatHistory ?? MemoryChatHistoryStorage(),
      statementHistory: statementHistory,
      fileShare: fileShare,
      biometric: biometric,
      appLock: appLock,
      // Never the real internet in tests.
      market:
          market ??
          MarketService(
            client: MockClient((_) async => http.Response('offline', 503)),
          ),
      debts: debts,
      personal: personal ?? MemoryPersonalFinanceStorage(),
      reminders: reminders ?? FakeReminderService(),
      filePick: filePick ?? FakeFilePickService(),
      sessionRetryDelay: Duration.zero,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  // Lazy lists build only what is on screen: scroll down until it is.
  if (find.text(text).evaluate().isEmpty) {
    final lists = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: lists.last,
    );
  }
  final finder = find.text(text).last;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The editable text of the field labelled [label].
Finder fieldWithLabel(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(EditableText),
);

/// Salaries are opened from the "+" sheet (they are no longer a tab).
Future<void> openPayroll(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Добавить'));
  await tester.pumpAndSettle();
  await tapText(tester, 'Зарплаты');
}

/// Home is the personal accountant; the shop's dashboard opens from "Мой
/// бизнес" → "Открыть" (there is a store in [stubHome]).
Future<void> openBusiness(WidgetTester tester) async {
  final open = find.text('Открыть');
  await tester.scrollUntilVisible(
    open,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(open);
  await tester.pumpAndSettle();
}

/// "Ещё" → "Отчёты" (the business reports) → [item].
Future<void> openReport(WidgetTester tester, String item) async {
  await tapText(tester, 'Ещё');
  await tapText(tester, 'Отчёты');
  await tapText(tester, item);
}
