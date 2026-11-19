import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/models/biometric_kind.dart';
import 'package:subhon_app/views/auth_view.dart';
import 'package:subhon_app/views/lock_view.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/fake_biometric_service.dart';
import '../helpers/memory_token_storage.dart';

FakeBackend _backend() {
  final backend = FakeBackend()
    ..json('GET', '/api/auth/me', ApiJson.profile())
    ..json('GET', '/api/profile', ApiJson.profile())
    ..on(
      'POST',
      '/api/auth/logout',
      (_) => FakeBackend.respond(null, status: 204),
    );
  stubHome(backend);
  return backend;
}

Future<void> _openSettings(WidgetTester tester) async {
  await tapText(tester, 'Ещё');
  await tapText(tester, 'Профиль и настройки');
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('settings: "Вход по Face ID" turns on after Face ID', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final face = FakeBiometricService();
    final lock = MemoryAppLockStorage();
    await pumpApp(
      tester,
      _backend(),
      biometric: face,
      appLock: lock,
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await _openSettings(tester);
    expect(find.text('Безопасность'), findsOneWidget);
    expect(find.text('Вход по Face ID'), findsOneWidget);

    // Face ID refused: stays off.
    face.answer = false;
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(lock.enabled, isFalse);
    expect(find.textContaining('Не подтверждено'), findsOneWidget);

    face.answer = true;
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(lock.enabled, isTrue);
    expect(face.prompts, 2);
    // Turning it on does not lock the open app.
    expect(find.byType(LockView), findsNothing);

    // Off: no Face ID needed.
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(lock.enabled, isFalse);
    expect(face.prompts, 2);
  });

  testWidgets('the lock covers the app at start and after the background; '
      'Face ID opens it', (tester) async {
    final face = FakeBiometricService()..answer = false;
    await pumpApp(
      tester,
      _backend(),
      biometric: face,
      appLock: MemoryAppLockStorage(enabled: true),
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    expect(find.byType(LockView), findsOneWidget);
    expect(find.text('OFAR заблокирован'), findsOneWidget);
    expect(face.prompts, 1); // asked at once

    face.answer = true;
    await tapText(tester, 'Разблокировать');
    expect(find.byType(LockView), findsNothing);
    expect(find.text('Мои деньги'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(face.prompts, 3);
    expect(find.byType(LockView), findsNothing); // opened again by Face ID
  });

  testWidgets('locked: "Выйти из аккаунта" signs out to the login screen', (
    tester,
  ) async {
    await pumpApp(
      tester,
      _backend(),
      biometric: FakeBiometricService()..answer = false,
      appLock: MemoryAppLockStorage(enabled: true),
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await tapText(tester, 'Выйти из аккаунта');
    expect(find.byType(AuthView), findsOneWidget);
    expect(find.byType(LockView), findsNothing);
  });

  testWidgets('no Face ID on the phone: the switch is off and disabled', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(
      tester,
      _backend(),
      biometric: FakeBiometricService(available: BiometricKind.none),
      appLock: MemoryAppLockStorage(),
      tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
    );
    await _openSettings(tester);
    expect(
      find.text('На этом телефоне не настроены Face ID или отпечаток'),
      findsOneWidget,
    );
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });
}
