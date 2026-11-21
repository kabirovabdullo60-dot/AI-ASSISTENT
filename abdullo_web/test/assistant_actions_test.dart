import 'package:abdullo_web/core/navigation/app_section.dart';
import 'package:abdullo_web/models/assistant_action_model.dart';
import 'package:abdullo_web/models/chat_message_model.dart';
import 'package:abdullo_web/views/stores_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<void> _ask(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('chat-input')), text);
  await tester.tap(find.byKey(const Key('chat-send')));
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  test('AssistantActionOut JSON round trip, also inside a saved message', () {
    final json = {
      'id': 'a1',
      'type': 'DELETE_STORE',
      'status': 'FAILED',
      'summary': 'Delete store «Somoni»',
      'danger': true,
      'params': {'id': 's2'},
      'result': null,
      'error': {'code': 'STORE_HAS_ACTIVE_EMPLOYEES', 'message': '…'},
      'createdAt': '2026-11-20T08:00:00Z',
      'expiresAt': '2026-11-20T08:30:00Z',
    };
    final a = AssistantActionModel.fromJson(json);
    expect(a.status, ActionStatus.failed);
    expect(a.subject, 'STORE');
    expect(a.danger, isTrue);
    expect(a.errorCode, 'STORE_HAS_ACTIVE_EMPLOYEES');
    expect(a.isPending(), isFalse);

    final m = ChatMessageModel.fromJson({
      'role': 'assistant',
      'text': 'Ok',
      'time': '2026-11-20T08:00:00Z',
      'actions': [json],
    });
    final back = ChatMessageModel.fromJson(m.toJson());
    expect(back.actions.single.type, 'DELETE_STORE');
    expect(back.actions.single.status, ActionStatus.failed);
    expect(
      ChatMessageModel.fromJson({'role': 'assistant', 'text': 'x', 'time': '2026-11-20T08:00:00Z'}).actions,
      isEmpty,
    );
  });

  for (final width in [mobileWidth, desktopWidth]) {
    final w = '${width.toInt()}px';

    testWidgets('AI adds a store after Confirm at $w', (tester) async {
      final backend = setUpBackend()..assistantReply = 'I can add it. Press Confirm.';
      await pumpApp(tester, width, backend: backend);
      await openSection(tester, AppSection.assistant);
      final action = backend.proposeAction('CREATE_STORE', {
        'name': 'Navruz Mall',
        'address': '7 Ismoili Somoni Ave',
      }, summary: 'Add store «Navruz Mall»');
      backend.nextActions = [action];
      final id = action['id'] as String;

      await _ask(tester, 'Add a store Navruz Mall on 7 Ismoili Somoni Ave');
      expect(find.text('Add store «Navruz Mall»'), findsOneWidget);
      expect(find.textContaining('name: Navruz Mall'), findsOneWidget);
      expect(find.text('Needs your confirmation'), findsOneWidget);
      expect(backend.stores.where((s) => s['name'] == 'Navruz Mall'), isEmpty, reason: 'nothing before Confirm');

      await _tapVisible(tester, find.byKey(Key('action-confirm-$id')));
      expect(backend.requests, contains('POST /api/assistant/actions/$id/confirm'));
      expect(backend.stores.where((s) => s['name'] == 'Navruz Mall'), hasLength(1));
      expect(find.text('Done'), findsOneWidget);
      expect(find.byKey(Key('action-confirm-$id')), findsNothing);

      // The Stores page already has it (reloaded after the action).
      await _tapVisible(tester, find.byKey(Key('action-open-$id')));
      expect(find.byType(StoresView), findsOneWidget);
      final newId = backend.stores.firstWhere((s) => s['name'] == 'Navruz Mall')['id'];
      await scrollTo(tester, find.byKey(Key('store-card-$newId')));
      expect(
        find.descendant(of: find.byKey(Key('store-card-$newId')), matching: find.text('Navruz Mall')),
        findsOneWidget,
      );
    });

    testWidgets('cancel, delete (red), expired and failed actions at $w', (tester) async {
      final backend = setUpBackend()..assistantReply = 'Here are the changes.';
      await pumpApp(tester, width, backend: backend);
      await openSection(tester, AppSection.assistant);
      final cancel = backend.proposeAction('CREATE_EXPENSE', {'amount': '50.00'}, summary: 'Add expense 50 TJS');
      final delete = backend.proposeAction('DELETE_STORE', {'id': 's3'}, summary: 'Delete store «Bokhtar Express»');
      final expired = backend.proposeAction('CREATE_SALE', {'amount': '10.00'}, summary: 'Record sale', expired: true);
      final taken = backend.proposeAction('CREATE_STORE', {
        'name': 'Central Plaza',
      }, summary: 'Add store «Central Plaza»');
      backend.nextActions = [cancel, delete, expired, taken];
      await _ask(tester, 'Do these');

      await _tapVisible(tester, find.byKey(Key('action-cancel-${cancel['id']}')));
      expect(find.text('Cancelled — ask the assistant again'), findsOneWidget);

      final del = find.byKey(Key('action-confirm-${delete['id']}'));
      expect(find.descendant(of: del, matching: find.text('Delete')), findsOneWidget);
      await _tapVisible(tester, del);
      // Deletes ask once more.
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(backend.stores.firstWhere((s) => s['id'] == 's3')['deletedAt'], isNull);
      await tester.tap(find.byKey(const Key('action-sure')));
      await tester.pumpAndSettle();
      expect(backend.stores.firstWhere((s) => s['id'] == 's3')['deletedAt'], isNotNull);

      // Past expiresAt: no buttons, "ask again".
      expect(find.byKey(Key('action-confirm-${expired['id']}')), findsNothing);
      expect(find.text('Expired — ask again'), findsOneWidget);

      await _tapVisible(tester, find.byKey(Key('action-confirm-${taken['id']}')));
      expect(find.text('A store with this name already exists.'), findsOneWidget);

      // FAILED → Edit the name and confirm again: only the changed field is sent.
      await _tapVisible(tester, find.byKey(Key('action-edit-${taken['id']}')));
      await tester.enterText(find.byKey(const Key('action-field-name')), 'Central Plaza 2');
      await tester.tap(find.byKey(const Key('action-edit-save')));
      await tester.pumpAndSettle();
      expect(backend.lastConfirmParams, {'name': 'Central Plaza 2'});
      expect(backend.stores.where((s) => s['name'] == 'Central Plaza 2'), hasLength(1));
      expect(find.byKey(Key('action-open-${taken['id']}')), findsOneWidget);
    });

    testWidgets('a slow answer shows the "up to 30 seconds" note at $w', (tester) async {
      final backend = setUpBackend()..assistantReply = 'Done thinking.';
      await pumpApp(tester, width, backend: backend);
      await openSection(tester, AppSection.assistant);
      backend.latency = const Duration(seconds: 12);
      await tester.enterText(find.byKey(const Key('chat-input')), 'Analyse everything');
      await tester.tap(find.byKey(const Key('chat-send')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(const Key('assistant-slow')), findsNothing);
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Working on it… this can take up to 30 seconds.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expect(find.text('Done thinking.'), findsOneWidget);
      // The history list refreshes behind the answer (another slow request).
      await tester.pump(const Duration(seconds: 13));
      await tester.pumpAndSettle();
    });
  }

  testWidgets('a reopened chat shows each action with its current status', (tester) async {
    final backend = setUpBackend()..assistantReply = 'Press Confirm.';
    await pumpApp(tester, desktopWidth, backend: backend);
    await openSection(tester, AppSection.assistant);
    final add = backend.proposeAction('CREATE_STORE', {'name': 'Pamir Mall'}, summary: 'Add store «Pamir Mall»');
    final skip = backend.proposeAction('CREATE_EXPENSE', {'amount': '9.00'}, summary: 'Add expense 9 TJS');
    backend.nextActions = [add, skip];
    await _ask(tester, 'Add Pamir Mall and an expense');
    await _tapVisible(tester, find.byKey(Key('action-confirm-${add['id']}')));
    await _tapVisible(tester, find.byKey(Key('action-cancel-${skip['id']}')));

    // Start a new chat, then reopen this one from the history: cards come from messages[].actions.
    await tester.tap(find.byKey(const Key('chat-new')));
    await tester.pumpAndSettle();
    expect(find.text('Add store «Pamir Mall»'), findsNothing);
    await tester.tap(
      find.descendant(of: find.byKey(const Key('history-panel')), matching: find.text('Add Pamir Mall and an expense')),
    );
    await tester.pumpAndSettle();
    expect(backend.requests.where((r) => r.startsWith('GET /api/assistant/conversations/')), isNotEmpty);
    expect(find.text('Add store «Pamir Mall»'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Cancelled — ask the assistant again'), findsOneWidget);
  });

  testWidgets('a confirm that is already handled elsewhere shows the real status', (tester) async {
    final backend = setUpBackend()..assistantReply = 'Ok.';
    await pumpApp(tester, desktopWidth, backend: backend);
    await openSection(tester, AppSection.assistant);
    final a = backend.proposeAction('CREATE_EXPENSE', {'amount': '5.00'}, summary: 'Add expense 5 TJS');
    backend.nextActions = [a];
    await _ask(tester, 'Add expense 5');
    a['status'] = 'CANCELLED'; // cancelled on the phone meanwhile
    await _tapVisible(tester, find.byKey(Key('action-confirm-${a['id']}')));
    expect(backend.requests, contains('GET /api/assistant/actions/${a['id']}'));
    expect(find.text('Cancelled — ask the assistant again'), findsOneWidget);
  });
}
