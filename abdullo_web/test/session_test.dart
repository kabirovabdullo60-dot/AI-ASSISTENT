import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/core/network/api_client.dart';
import 'package:abdullo_web/core/network/token_storage.dart';
import 'package:abdullo_web/main.dart';
import 'package:abdullo_web/views/login_view.dart';
import 'package:abdullo_web/views/stores_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

/// Signed-in browser storage with a sign-in made [age] ago.
FakeBackend _signedInFor(Duration age, {String? section}) {
  final backend = setUpBackend();
  SharedPreferences.setMockInitialValues({
    'accessToken': 'access-start',
    'refreshToken': 'refresh-start',
    'sessionStartedAt': DateTime.now().subtract(age).toIso8601String(),
    'section': ?section,
  });
  return backend;
}

void main() {
  testWidgets('a sign-in from 6 days ago is restored without asking to log in', (tester) async {
    final backend = _signedInFor(const Duration(days: 6));
    await pumpApp(tester, desktopWidth, backend: backend);
    expect(find.byType(LoginView), findsNothing);
    expect(find.text('Overview'), findsOneWidget);
  });

  testWidgets('after 7 days the login is asked again and the tokens are gone', (tester) async {
    final backend = _signedInFor(const Duration(days: 7, hours: 1));
    await pumpApp(tester, desktopWidth, backend: backend);
    expect(find.byType(LoginView), findsOneWidget);
    expect(backend.requests, contains('POST /api/auth/logout'));
    expect((await SharedPreferences.getInstance()).getString('refreshToken'), isNull);
  });

  testWidgets('a session saved before the 7-day rule starts counting now', (tester) async {
    await pumpApp(tester, desktopWidth); // storage has tokens but no sessionStartedAt
    expect(find.text('Overview'), findsOneWidget);
    expect((await SharedPreferences.getInstance()).getString('sessionStartedAt'), isNotNull);
  });

  testWidgets('logging in records when the session started', (tester) async {
    await pumpApp(tester, desktopWidth, signedIn: false);
    await tester.enterText(find.byKey(const Key('login-email')), 'owner@test.tj');
    await tester.enterText(find.byKey(const Key('login-password')), FakeBackend.password);
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    final started = DateTime.parse((await SharedPreferences.getInstance()).getString('sessionStartedAt')!);
    expect(DateTime.now().difference(started).inMinutes, lessThan(1));
  });

  testWidgets('a reload comes back to the page that was open', (tester) async {
    final backend = _signedInFor(const Duration(hours: 1));
    tester.view.physicalSize = const Size(desktopWidth, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      WebApp(httpClient: backend.client, splashDuration: Duration.zero, initialSection: AppSection.stores),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StoresView), findsOneWidget);

    await openSection(tester, AppSection.salaries);
    expect((await SharedPreferences.getInstance()).getString('section'), 'salaries');
  });

  test('another tab already refreshed the tokens: take theirs, do not reuse the old one', () async {
    final backend = setUpBackend();
    SharedPreferences.setMockInitialValues({'accessToken': 'access-start', 'refreshToken': 'refresh-start'});
    final tokens = TokenStorage();
    await tokens.load();
    final api = ApiClient(client: backend.client, tokens: tokens);
    // The other tab rotates the pair: the server now only knows refresh-2 / access-2.
    backend
      ..refreshToken = 'refresh-2'
      ..accessToken = 'access-2';
    (await SharedPreferences.getInstance())
      ..setString('accessToken', 'access-2')
      ..setString('refreshToken', 'refresh-2');

    expect(await api.refreshTokens(), isTrue);
    expect(backend.requests, isNot(contains('POST /api/auth/refresh')));
    expect(tokens.refreshToken, 'refresh-2');
    expect(tokens.accessToken, 'access-2');
  });

  test('no network during a refresh keeps the tokens (nobody is logged out)', () async {
    SharedPreferences.setMockInitialValues({'accessToken': 'access-start', 'refreshToken': 'refresh-start'});
    final tokens = TokenStorage();
    await tokens.load();
    final api = ApiClient(client: FakeBackendClientThatThrows(), tokens: tokens);
    await expectLater(api.refreshTokens(), throwsA(isA<Exception>()));
    expect(tokens.refreshToken, 'refresh-start');
    expect((await SharedPreferences.getInstance()).getString('refreshToken'), 'refresh-start');
  });
}
