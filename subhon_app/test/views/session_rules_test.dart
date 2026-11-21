import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  testWidgets('no connection at start: 3 tries, then "Нет связи" — the '
      'session stays; "Повторить" signs in once it is back', (tester) async {
    var online = false;
    var tries = 0;
    final backend = FakeBackend();
    stubHome(backend);
    backend.on('GET', '/api/auth/me', (_) {
      tries++;
      if (!online) throw http.ClientException('offline');
      return FakeBackend.respond(ApiJson.profile());
    });
    final tokens = MemoryTokenStorage(
      accessToken: 'a',
      refreshToken: 'r',
      signedInAt: DateTime.now(),
    );
    await pumpApp(tester, backend, tokens: tokens);
    expect(tries, 3);
    expect(find.text('Нет связи с сервером'), findsOneWidget);
    expect(find.text('Войти'), findsNothing);
    expect(tokens.refreshToken, 'r');

    online = true;
    await tapText(tester, 'Повторить');
    expect(find.text('Мои деньги'), findsOneWidget);
  });

  testWidgets('a server error (5xx) at start does not sign out', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..on(
        'GET',
        '/api/auth/me',
        (_) => FakeBackend.error(503, 'SERVICE_UNAVAILABLE', 'down'),
      );
    final tokens = MemoryTokenStorage(
      accessToken: 'a',
      refreshToken: 'r',
      signedInAt: DateTime.now(),
    );
    await pumpApp(tester, backend, tokens: tokens);
    expect(find.text('Нет связи с сервером'), findsOneWidget);
    expect(tokens.refreshToken, 'r');
  });

  testWidgets('the server ended the session (401): the login shows', (
    tester,
  ) async {
    final backend = FakeBackend()
      ..on(
        'GET',
        '/api/auth/me',
        (_) => FakeBackend.error(401, 'AUTH_SESSION_REVOKED', 'revoked'),
      );
    final tokens = MemoryTokenStorage(
      accessToken: 'a',
      refreshToken: 'r',
      signedInAt: DateTime.now(),
    );
    await pumpApp(tester, backend, tokens: tokens);
    expect(find.text('Нет связи с сервером'), findsNothing);
    expect(tokens.refreshToken, isNull);
    expect(backend.calls('GET', '/api/auth/me'), hasLength(1));
  });

  testWidgets('signed in 8 days ago: the login is asked for again with a '
      'note; the server session is ended', (tester) async {
    final backend = FakeBackend()
      ..json('GET', '/api/auth/me', ApiJson.profile())
      ..json('POST', '/api/auth/logout', null);
    final tokens = MemoryTokenStorage(
      accessToken: 'a',
      refreshToken: 'r',
      signedInAt: DateTime.now().subtract(const Duration(days: 8)),
    );
    await pumpApp(tester, backend, tokens: tokens);
    expect(
      find.text('Для безопасности войдите снова (раз в неделю).'),
      findsOneWidget,
    );
    expect(tokens.refreshToken, isNull);
    expect(backend.calls('POST', '/api/auth/logout'), hasLength(1));
    expect(backend.calls('GET', '/api/auth/me'), isEmpty);
  });

  testWidgets('a login saves when it happened', (tester) async {
    final backend = FakeBackend()
      ..json('POST', '/api/auth/login', ApiJson.auth());
    stubHome(backend);
    final tokens = MemoryTokenStorage();
    await pumpApp(tester, backend, tokens: tokens);
    await tester.enterText(fieldWithLabel('E-mail'), 'a@b.tj');
    await tester.enterText(fieldWithLabel('Пароль'), 'Ofar2026');
    await tapText(tester, 'Войти');
    expect(tokens.signedInAt, isNotNull);
    expect(
      DateTime.now().difference(tokens.signedInAt!).inMinutes,
      lessThan(1),
    );
  });
}
