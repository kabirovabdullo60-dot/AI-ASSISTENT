import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subhon_app/core/network/api_client.dart';
import 'package:subhon_app/services/assistant_service.dart';
import 'package:subhon_app/viewmodels/chat_view_model.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

const _a1 = 'a1111111-1111-1111-1111-111111111111';
const _a2 = 'a2222222-2222-2222-2222-222222222222';

Map<String, Object?> _action(
  String id, {
  String status = 'PROPOSED',
  bool danger = false,
  String summary = 'Добавить магазин «Центр», пр. Рудаки 45',
  String? error,
}) => {
  'id': id,
  'type': danger ? 'DELETE_STORE' : 'CREATE_STORE',
  'status': status,
  'summary': summary,
  'danger': danger,
  'params': {'name': 'Центр'},
  'result': null,
  'error': error == null ? null : {'code': error, 'message': 'x'},
  'createdAt': '2026-11-21T09:00:00Z',
  'expiresAt': '2026-11-21T09:30:00Z',
};

Map<String, Object?> _reply(List<Map<String, Object?>> actions) => {
  'role': 'assistant',
  'text': 'Предлагаю:',
  'time': '2026-11-21T09:00:00Z',
  'conversationId': 'c1111111-1111-1111-1111-111111111111',
  'actions': actions,
};

Future<FakeBackend> _chatWith(
  WidgetTester tester,
  List<Map<String, Object?>> actions, {
  Size size = const Size(390, 844),
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final backend = FakeBackend()
    ..json('GET', '/api/auth/me', ApiJson.profile())
    ..json('POST', '/api/assistant/chat', _reply(actions));
  stubHome(backend);
  await pumpApp(
    tester,
    backend,
    tokens: MemoryTokenStorage(accessToken: 'a', refreshToken: 'r'),
  );
  await tester.tap(find.byTooltip('ИИ-ассистент'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), 'Добавь магазин Центр');
  await tester.tap(find.byTooltip('Отправить'));
  await tester.pumpAndSettle();
  return backend;
}

void main() {
  for (final size in const [Size(360, 640), Size(430, 932)]) {
    testWidgets('a proposal shows its summary with Отмена / Подтвердить; '
        'Confirm → DONE "Готово" and the other screens reload '
        '(${size.width.toInt()} px)', (tester) async {
      final backend = await _chatWith(tester, [_action(_a1)], size: size);
      expect(
        find.text('Добавить магазин «Центр», пр. Рудаки 45'),
        findsOneWidget,
      );
      expect(find.text('Отмена'), findsOneWidget);
      final dashboardBefore = backend
          .calls('GET', '/api/reports/dashboard')
          .length;
      backend.json(
        'POST',
        '/api/assistant/actions/$_a1/confirm',
        _action(_a1, status: 'DONE'),
      );
      await tapText(tester, 'Подтвердить');
      expect(find.text('Готово'), findsOneWidget);
      expect(find.text('Подтвердить'), findsNothing);
      expect(
        backend.calls('GET', '/api/reports/dashboard').length,
        greaterThan(dashboardBefore),
      );
    });
  }

  testWidgets('a delete: red button and "Вы уверены?" first; Cancel → '
      'greyed "Отменено"', (tester) async {
    final backend = await _chatWith(tester, [
      _action(_a1, danger: true, summary: 'Удалить магазин «Центр»'),
      _action(_a2),
    ]);
    backend.json(
      'POST',
      '/api/assistant/actions/$_a1/confirm',
      _action(_a1, status: 'DONE', danger: true),
    );
    await tester.tap(find.text('Подтвердить').first);
    await tester.pumpAndSettle();
    expect(find.text('Вы уверены?'), findsOneWidget);
    // "No" in the dialog: nothing is sent.
    await tapText(tester, 'Отмена');
    expect(
      backend.calls('POST', '/api/assistant/actions/$_a1/confirm'),
      isEmpty,
    );

    backend.json(
      'POST',
      '/api/assistant/actions/$_a2/cancel',
      _action(_a2, status: 'CANCELLED'),
    );
    await tester.tap(find.text('Отмена').last);
    await tester.pumpAndSettle();
    expect(find.text('Отменено · спросите ассистента снова'), findsOneWidget);
  });

  testWidgets('FAILED shows the translated reason and "Подтвердить снова"; '
      'already handled (409) shows its real status', (tester) async {
    final backend = await _chatWith(tester, [_action(_a1), _action(_a2)]);
    backend
      ..json(
        'POST',
        '/api/assistant/actions/$_a1/confirm',
        _action(_a1, status: 'FAILED', error: 'STORE_NAME_TAKEN'),
      )
      ..on(
        'POST',
        '/api/assistant/actions/$_a2/confirm',
        (_) => FakeBackend.error(409, 'ACTION_ALREADY_HANDLED', 'x'),
      )
      ..json(
        'GET',
        '/api/assistant/actions/$_a2',
        _action(_a2, status: 'EXPIRED'),
      );
    await tester.tap(find.text('Подтвердить').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('Не выполнено:'), findsOneWidget);
    expect(find.text('Подтвердить снова'), findsOneWidget);

    await tester.tap(find.text('Подтвердить').last);
    await tester.pumpAndSettle();
    expect(backend.calls('GET', '/api/assistant/actions/$_a2'), hasLength(1));
    expect(find.text('Устарело · спросите ассистента снова'), findsOneWidget);
  });

  test('both buttons are off while a request runs; a second tap sends '
      'nothing', () async {
    final backend = FakeBackend();
    final gate = Completer<void>();
    backend
      ..json('POST', '/api/assistant/chat', _reply([_action(_a1)]))
      ..on('POST', '/api/assistant/actions/$_a1/confirm', (_) {
        return FakeBackend.respond(_action(_a1, status: 'DONE'));
      });
    final vm = ChatViewModel(
      AssistantService(
        ApiClient(
          tokens: MemoryTokenStorage(accessToken: 'a'),
          client: backend.client,
        ),
      ),
    );
    await vm.send('Добавь магазин Центр', 'ru');
    final first = vm.confirmAction(_a1);
    expect(vm.isActionBusy(_a1), isTrue);
    await vm.confirmAction(_a1); // ignored
    await vm.cancelAction(_a1); // ignored
    gate.complete();
    await first;
    expect(vm.isActionBusy(_a1), isFalse);
    expect(
      backend.calls('POST', '/api/assistant/actions/$_a1/confirm'),
      hasLength(1),
    );
    expect(
      backend.calls('POST', '/api/assistant/actions/$_a1/cancel'),
      isEmpty,
    );
    final body = jsonDecode(
      backend.calls('POST', '/api/assistant/chat').single.body,
    );
    expect(body['language'], 'ru');
  });
}
