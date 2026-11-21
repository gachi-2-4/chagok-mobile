import 'dart:async';

import 'package:chagok_mobile/core/constants/core_strings.dart';
import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/in_memory_token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../helpers/fake_api_server.dart';

void main() {
  late FakeApiServer server;

  setUp(() async {
    server = FakeApiServer();
    await server.tokenStorage.save(FakeApiServer.loggedInTokens);
  });

  /// 새 토큰을 주는 재발급 응답을 정합니다.
  void allowRefresh() {
    server.onJson('POST', '/auth/token/refresh', {
      'accessToken': 'access-2',
      'refreshToken': 'refresh-2',
      'accessTokenExpiresIn': 3600,
      'refreshTokenExpiresIn': 1209600,
    });
  }

  /// 처음 토큰으로 부르면 만료로, 새 토큰으로 부르면 성공으로 답하는 `/boxes`.
  void expireFirstToken() {
    server.on('GET', '/boxes', (request) {
      return request.headers['Authorization'] == 'Bearer access-1'
          ? errorResponse(401, 'TOKEN_EXPIRED')
          : jsonResponse({'content': <Object>[]});
    });
  }

  group('ApiClient', () {
    test('토큰이 있으면 Authorization 헤더에 Access Token을 붙인다', () async {
      server.onJson('GET', '/boxes', {'content': <Object>[]});

      await server.client.get('/boxes');

      expect(
        server.requests.single.headers['Authorization'],
        'Bearer access-1',
      );
    });

    test('로그인 전 API로 보내면 Authorization 헤더를 붙이지 않는다', () async {
      server.onJson('POST', '/auth/login', {});

      await server.client.post('/auth/login', isAuthenticated: false);

      expect(server.requests.single.headers, isNot(contains('Authorization')));
    });

    test('본문을 보내면 JSON으로 바꿔 보낸다', () async {
      server.onJson('PATCH', '/user/me/preferences', {});

      await server.client.patch(
        '/user/me/preferences',
        body: {'fontSize': 'LARGE'},
      );

      expect(server.lastBody('PATCH', '/user/me/preferences'), {
        'fontSize': 'LARGE',
      });
    });

    test('쿼리에 null 값과 목록이 있으면 null은 빼고 목록은 쉼표로 이어 보낸다', () async {
      server.onJson('GET', '/documents', {'content': <Object>[]});

      await server.client.get(
        '/documents',
        query: {
          'boxId': 1,
          'keyword': null,
          'docCategory': ['AD', 'INFO'],
        },
      );

      expect(server.requests.single.url.queryParameters, {
        'boxId': '1',
        'docCategory': 'AD,INFO',
      });
    });

    test('서버 주소에 경로가 있으면 그 뒤에 API 경로를 붙인다', () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          return jsonResponse({});
        }),
        baseUrl: Uri.parse('https://api.test/v1/'),
        tokenStorage: InMemoryTokenStorage(),
      );

      await client.get('/home');

      expect(requests.single.url.toString(), 'https://api.test/v1/home');
    });

    test('HTTPS가 아닌 주소면 보내지 않고 StateError를 던진다', () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          return jsonResponse({});
        }),
        baseUrl: Uri.parse('http://api.test'),
        tokenStorage: InMemoryTokenStorage(),
      );

      await expectLater(client.get('/home'), throwsStateError);
      expect(requests, isEmpty);
    });

    test('기기 안 개발 서버 주소면 HTTP로도 보낸다', () async {
      final client = ApiClient(
        httpClient: MockClient((_) async => jsonResponse({'ok': true})),
        baseUrl: Uri.parse('http://localhost:8080'),
        tokenStorage: InMemoryTokenStorage(),
      );

      expect(await client.get('/home'), {'ok': true});
    });

    test('요청을 보내면 리디렉션을 따라가지 않게 한다', () async {
      server.onJson('GET', '/home', {});

      await server.client.get('/home');

      expect(server.requests.single.followRedirects, isFalse);
    });

    test('본문이 없는 응답이면 빈 객체를 돌려준다', () async {
      server.on('DELETE', '/documents/1', (_) => emptyResponse());

      final json = await server.client.delete('/documents/1');

      expect(json, isEmpty);
    });

    test('실패 응답이면 서버의 code와 message를 담아 던진다', () async {
      server.on(
        'GET',
        '/documents/1',
        (_) => errorResponse(404, 'DOCUMENT_NOT_FOUND', '서류를 찾을 수 없어요.'),
      );

      final request = server.client.get('/documents/1');

      await expectLater(
        request,
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'statusCode', 404)
              .having((error) => error.code, 'code', 'DOCUMENT_NOT_FOUND')
              .having((error) => error.message, 'message', '서류를 찾을 수 없어요.'),
        ),
      );
    });

    test('실패 응답이 JSON이 아니면 상태 코드로 에러를 만든다', () async {
      server.on('GET', '/home', (_) => http.Response('Bad Gateway', 502));

      final request = server.client.get('/home');

      await expectLater(
        request,
        throwsA(
          isA<ApiException>()
              .having((error) => error.code, 'code', 'HTTP_502')
              .having(
                (error) => error.message,
                'message',
                CoreStrings.unknownError,
              ),
        ),
      );
    });

    test('서버에 닿지 못하면 NETWORK_ERROR로 던진다', () async {
      final client = ApiClient(
        httpClient: MockClient((_) => throw http.ClientException('끊김')),
        baseUrl: FakeApiServer.baseUrl,
        tokenStorage: InMemoryTokenStorage(),
      );

      final request = client.get('/home');

      await expectLater(
        request,
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            ApiException.networkErrorCode,
          ),
        ),
      );
    });

    test('Access Token이 만료되면 재발급한 토큰으로 다시 보낸다', () async {
      allowRefresh();
      expireFirstToken();

      await server.client.get('/boxes');

      final retried = server.requestsTo('GET', '/boxes').last;
      expect(retried.headers['Authorization'], 'Bearer access-2');
    });

    test('재발급하면 새 토큰을 저장한다', () async {
      allowRefresh();
      expireFirstToken();

      await server.client.get('/boxes');

      final tokens = await server.tokenStorage.read();
      expect(tokens?.refreshToken, 'refresh-2');
    });

    test('여러 요청이 동시에 만료되면 재발급은 한 번만 부른다', () async {
      final refreshGate = Completer<void>();
      server.on('POST', '/auth/token/refresh', (_) async {
        await refreshGate.future;
        return jsonResponse({
          'accessToken': 'access-2',
          'refreshToken': 'refresh-2',
        });
      });
      expireFirstToken();

      final requests = Future.wait([
        server.client.get('/boxes'),
        server.client.get('/boxes'),
        server.client.get('/boxes'),
      ]);
      await pumpEventQueue();
      refreshGate.complete();
      await requests;

      expect(server.requestsTo('POST', '/auth/token/refresh'), hasLength(1));
    });

    test('재발급도 401이면 토큰을 지우고 SESSION_EXPIRED로 던진다', () async {
      server.on(
        'POST',
        '/auth/token/refresh',
        (_) => errorResponse(401, 'REFRESH_TOKEN_EXPIRED', '다시 로그인해 주세요.'),
      );
      expireFirstToken();

      await expectLater(
        server.client.get('/boxes'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            ApiException.sessionExpiredCode,
          ),
        ),
      );
      expect(await server.tokenStorage.read(), isNull);
    });

    test('재발급이 서버 오류로 실패하면 토큰을 지우지 않는다', () async {
      server.on(
        'POST',
        '/auth/token/refresh',
        (_) => errorResponse(500, 'INTERNAL_SERVER_ERROR'),
      );
      expireFirstToken();

      await expectLater(
        server.client.get('/boxes'),
        throwsA(isA<ApiException>()),
      );
      expect(await server.tokenStorage.read(), isA<AuthTokens>());
    });

    test('재발급을 기다리는 사이 로그아웃하면 이전 세션의 토큰을 다시 저장하지 않는다', () async {
      final refreshGate = Completer<void>();
      server.on('POST', '/auth/token/refresh', (_) async {
        await refreshGate.future;
        return jsonResponse({
          'accessToken': 'access-2',
          'refreshToken': 'refresh-2',
        });
      });
      expireFirstToken();

      final request = server.client.get('/boxes');
      await pumpEventQueue();
      await server.tokenStorage.clear();
      refreshGate.complete();

      await expectLater(
        request,
        throwsA(
          isA<ApiException>().having(
            (error) => error.code,
            'code',
            ApiException.sessionExpiredCode,
          ),
        ),
      );
      expect(await server.tokenStorage.read(), isNull);
    });

    test('재발급을 기다리는 사이 다른 계정으로 로그인하면 새 토큰을 지우지 않는다', () async {
      final refreshGate = Completer<void>();
      server.on('POST', '/auth/token/refresh', (_) async {
        await refreshGate.future;
        return errorResponse(401, 'INVALID_REFRESH_TOKEN');
      });
      expireFirstToken();
      const other = AuthTokens(accessToken: 'other', refreshToken: 'other-r');

      final request = server.client.get('/boxes');
      await pumpEventQueue();
      await server.tokenStorage.save(other);
      refreshGate.complete();

      await expectLater(request, throwsA(isA<ApiException>()));
      expect((await server.tokenStorage.read())?.refreshToken, 'other-r');
    });

    test('만료가 아닌 401이면 재발급하지 않는다', () async {
      server.on('GET', '/boxes', (_) => errorResponse(401, 'UNAUTHORIZED'));

      await expectLater(
        server.client.get('/boxes'),
        throwsA(isA<ApiException>()),
      );
      expect(server.requestsTo('POST', '/auth/token/refresh'), isEmpty);
    });

    test('모든 쪽을 받으면 hasNext가 false인 쪽까지 content를 이어 붙인다', () async {
      server.on('GET', '/notifications', (request) {
        final page = int.parse(request.url.queryParameters['page'] ?? '0');
        return jsonResponse({
          'content': [
            {'id': page},
          ],
          'hasNext': page < 2,
        });
      });

      final items = await server.client.getAllPages('/notifications');

      expect(items.map((item) => item['id']), [0, 1, 2]);
    });

    test('최대 쪽수를 받아도 다음 쪽이 남아 있으면 StateError를 던진다', () async {
      server.onJson('GET', '/documents', {
        'content': <Object>[],
        'hasNext': true,
      });

      await expectLater(
        server.client.getAllPages('/documents'),
        throwsStateError,
      );
      expect(
        server.requestsTo('GET', '/documents'),
        hasLength(ApiClient.maxPageCount),
      );
    });

    test('모든 쪽을 받으면 쪽마다 최대 개수를 요청한다', () async {
      server.onJson('GET', '/chats', {'content': <Object>[], 'hasNext': false});

      await server.client.getAllPages('/chats');

      expect(
        server.requests.single.url.queryParameters['size'],
        '${ApiClient.maxPageSize}',
      );
    });
  });
}
