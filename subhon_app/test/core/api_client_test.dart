import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:subhon_app/core/network/api_client.dart';

import '../helpers/fake_backend.dart';
import '../helpers/memory_token_storage.dart';

void main() {
  late FakeBackend backend;
  late MemoryTokenStorage tokens;
  late ApiClient api;
  late int expired;

  setUp(() {
    backend = FakeBackend();
    tokens = MemoryTokenStorage(accessToken: 'old', refreshToken: 'r-old');
    api = ApiClient(
      tokens: tokens,
      client: backend.client,
      baseUrl: 'https://api.test',
      language: () => 'tg',
    );
    expired = 0;
    api.onSessionExpired = () => expired++;
  });

  test('protected calls carry the Bearer token and the app language', () async {
    backend.json('GET', '/api/profile', ApiJson.profile());
    await api.get('/api/profile');
    final request = backend.requests.single;
    expect(request.headers['Authorization'], 'Bearer old');
    expect(request.headers['Accept-Language'], 'tg');
    expect(request.url.toString(), 'https://api.test/api/profile');
  });

  test('null query values are not sent', () async {
    backend.json('GET', '/api/sales', ApiJson.page([]));
    await api.get('/api/sales', query: {'storeId': null, 'page': 2});
    expect(backend.requests.single.url.queryParameters, {'page': '2'});
  });

  test('401 AUTH_TOKEN_EXPIRED: one refresh, both new tokens saved, the '
      'call retried with the new token', () async {
    backend.on('GET', '/api/profile', (r) {
      return r.headers['Authorization'] == 'Bearer new'
          ? FakeBackend.respond(ApiJson.profile())
          : FakeBackend.error(401, 'AUTH_TOKEN_EXPIRED', 'expired');
    });
    backend.json('POST', '/api/auth/refresh', ApiJson.tokens('new', 'r-new'));
    final profile = await api.get('/api/profile') as Map<String, dynamic>;
    expect(profile['email'], 'farhod@bahor.tj');
    expect(backend.calls('POST', '/api/auth/refresh'), hasLength(1));
    expect(
      backend.calls('POST', '/api/auth/refresh').single.body,
      '{"refreshToken":"r-old"}',
    );
    expect(tokens.accessToken, 'new');
    expect(tokens.refreshToken, 'r-new');
    expect(expired, 0);
  });

  test('calls failing together share ONE refresh request', () async {
    final refreshGate = Completer<void>();
    backend.on('GET', '/api/stores', (r) {
      return r.headers['Authorization'] == 'Bearer new'
          ? FakeBackend.respond(ApiJson.page([]))
          : FakeBackend.error(401, 'AUTH_TOKEN_EXPIRED', 'expired');
    });
    final client = MockClient((request) async {
      if (request.url.path == '/api/auth/refresh') {
        await refreshGate.future;
      }
      return backend.handle(request);
    });
    api = ApiClient(
      tokens: tokens,
      client: client,
      baseUrl: 'https://api.test',
    );
    backend.json('POST', '/api/auth/refresh', ApiJson.tokens('new', 'r-new'));
    final calls = [for (var i = 0; i < 3; i++) api.get('/api/stores')];
    await Future<void>.delayed(const Duration(milliseconds: 10));
    refreshGate.complete();
    await Future.wait(calls);
    expect(backend.calls('POST', '/api/auth/refresh'), hasLength(1));
    expect(backend.calls('GET', '/api/stores'), hasLength(6));
    expect(tokens.refreshToken, 'r-new');
  });

  test('a failed refresh (AUTH_SESSION_REVOKED) clears the tokens and ends '
      'the session', () async {
    backend.on(
      'GET',
      '/api/profile',
      (_) => FakeBackend.error(401, 'AUTH_TOKEN_EXPIRED', 'expired'),
    );
    backend.on(
      'POST',
      '/api/auth/refresh',
      (_) => FakeBackend.error(401, 'AUTH_SESSION_REVOKED', 'revoked'),
    );
    await expectLater(
      api.get('/api/profile'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          'AUTH_SESSION_REVOKED',
        ),
      ),
    );
    expect(tokens.accessToken, isNull);
    expect(tokens.refreshToken, isNull);
    expect(expired, 1);
  });

  test('any other 401 on a protected call clears the tokens and ends the '
      'session — no refresh', () async {
    backend.on(
      'GET',
      '/api/profile',
      (_) => FakeBackend.error(401, 'AUTH_TOKEN_INVALID', 'invalid'),
    );
    await expectLater(api.get('/api/profile'), throwsA(isA<ApiException>()));
    expect(backend.calls('POST', '/api/auth/refresh'), isEmpty);
    expect(tokens.refreshToken, isNull);
    expect(expired, 1);
  });

  test(
    'a wrong password at login is an error, not the end of a session',
    () async {
      backend.on(
        'POST',
        '/api/auth/login',
        (_) => FakeBackend.error(401, 'AUTH_INVALID_CREDENTIALS', 'Wrong.'),
      );
      await expectLater(
        api.post('/api/auth/login', body: {}, auth: false),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'AUTH_INVALID_CREDENTIALS',
          ),
        ),
      );
      expect(tokens.refreshToken, 'r-old');
      expect(expired, 0);
    },
  );

  test(
    'errors become ApiException(statusCode, code, message, details)',
    () async {
      backend.on(
        'POST',
        '/api/stores',
        (_) => FakeBackend.error(
          422,
          'VALIDATION_ERROR',
          'Invalid.',
          details: [
            {
              'location': 'body',
              'field': 'name',
              'code': 'too_short',
              'message': 'Too short',
            },
          ],
        ),
      );
      try {
        await api.post('/api/stores', body: {'name': ''});
        fail('should throw');
      } on ApiException catch (e) {
        expect(e.statusCode, 422);
        expect(e.code, 'VALIDATION_ERROR');
        expect(e.message, 'Invalid.');
        expect(e.details.single['field'], 'name');
      }
    },
  );

  test('no connection → NETWORK_ERROR', () async {
    for (final failure in [
      const SocketException('offline'),
      http.ClientException('connection closed'),
    ]) {
      api = ApiClient(
        tokens: tokens,
        client: MockClient((_) async => throw failure),
        baseUrl: 'https://api.test',
      );
      await expectLater(
        api.get('/api/profile'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', ApiException.networkError)
              .having((e) => e.statusCode, 'status', 0),
        ),
      );
    }
  });

  test('a body that is not the error format → UNKNOWN_ERROR', () async {
    backend.on('GET', '/api/profile', (_) => http.Response('Bad gateway', 502));
    await expectLater(
      api.get('/api/profile'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiException.unknownError)
            .having((e) => e.statusCode, 'status', 502),
      ),
    );
  });

  test('multipart upload sends the file in the given field', () async {
    backend.json('PATCH', '/api/profile/avatar', ApiJson.profile());
    await api.uploadFile(
      '/api/profile/avatar',
      field: 'file',
      bytes: Uint8List.fromList([1, 2, 3]),
      filename: 'me.jpg',
    );
    final request = backend.requests.single;
    expect(request.headers['content-type'], startsWith('multipart/form-data'));
    final body = String.fromCharCodes(request.bodyBytes);
    expect(body, contains('name="file"'));
    expect(body, contains('filename="me.jpg"'));
  });
}
