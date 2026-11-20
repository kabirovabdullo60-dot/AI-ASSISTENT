import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

void main() {
  for (final width in [mobileWidth, desktopWidth]) {
    testWidgets('no saved session → login page; sign in → dashboard (${width.toInt()}px)', (tester) async {
      final backend = await pumpApp(tester, width, signedIn: false);
      expect(find.byType(LoginView), findsOneWidget);

      await tester.enterText(find.byKey(const Key('login-email')), 'owner@test.tj');
      await tester.enterText(find.byKey(const Key('login-password')), 'wrong');
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Incorrect email or password.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('login-password')), FakeBackend.password);
      await tester.tap(find.byKey(const Key('login-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Overview'), findsOneWidget);
      expect((await SharedPreferences.getInstance()).getString('refreshToken'), backend.refreshToken);
    });
  }

  testWidgets('register creates a business and opens the (empty) dashboard', (tester) async {
    await pumpApp(tester, desktopWidth, signedIn: false);
    await tester.tap(find.byKey(const Key('login-toggle')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('register-name')), 'Subhon Test');
    await tester.enterText(find.byKey(const Key('login-email')), 'new@test.tj');
    await tester.enterText(find.byKey(const Key('login-password')), 'pass1234');
    await tester.enterText(find.byKey(const Key('register-business')), 'New Shop');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('New Shop'), findsWidgets);
  });

  testWidgets('register with an existing email shows the translated error', (tester) async {
    await pumpApp(tester, desktopWidth, signedIn: false);
    await tester.tap(find.byKey(const Key('login-toggle')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('register-name')), 'X');
    await tester.enterText(find.byKey(const Key('login-email')), 'owner@test.tj');
    await tester.enterText(find.byKey(const Key('login-password')), 'pass1234');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('An account with this email already exists.'), findsOneWidget);
  });

  testWidgets('expired access token is refreshed once and the request retried', (tester) async {
    final backend = setUpBackend();
    backend.expireAccessOnce = true;
    await pumpApp(tester, desktopWidth, backend: backend);
    expect(find.text('Overview'), findsOneWidget);
    expect(backend.requests.where((r) => r == 'POST /api/auth/refresh'), hasLength(1));
    expect((await SharedPreferences.getInstance()).getString('accessToken'), backend.accessToken);
  });

  testWidgets('revoked session sends the user back to login', (tester) async {
    final backend = setUpBackend();
    backend.refreshToken = 'other';
    backend.expireAccessOnce = true;
    await pumpApp(tester, desktopWidth, backend: backend);
    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('sign out from the user menu', (tester) async {
    final backend = await pumpApp(tester, desktopWidth);
    await tester.tap(find.byKey(const Key('user-chip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('logout')));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    expect(backend.requests, contains('POST /api/auth/logout'));
    expect((await SharedPreferences.getInstance()).getString('refreshToken'), isNull);
  });

  testWidgets('login page language switch', (tester) async {
    await pumpApp(tester, mobileWidth, signedIn: false);
    await tester.tap(find.byKey(const Key('login-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TJ').last);
    await tester.pumpAndSettle();
    expect(find.text('Хуш омадед'), findsOneWidget);
    expect(AppSection.values, isNotEmpty);
  });
}
