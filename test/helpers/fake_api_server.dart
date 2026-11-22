import 'dart:async';
import 'dart:convert';

import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/in_memory_token_storage.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// 정해 둔 응답을 돌려주고 받은 요청을 기록하는 가짜 API 서버.
///
/// `server.onJson('GET', '/boxes', {...})`처럼 경로마다 응답의 `data`를 정합니다.
/// 실제 서버처럼 `{ success, data, error }`로 감싸 돌려줍니다.
/// 정하지 않은 경로는 404를 돌려줍니다.
class FakeApiServer {
  FakeApiServer() {
    _httpClient = MockClient(_handle);
  }

  /// 테스트용 서버 주소.
  static final baseUrl = Uri.parse('https://api.test');

  /// 받은 요청. 순서대로 쌓입니다.
  final requests = <http.Request>[];

  /// 토큰 저장소. 처음에는 [loggedInTokens]로 로그인한 상태입니다.
  final tokenStorage = InMemoryTokenStorage();

  /// 처음 저장해 둔 토큰.
  static const loggedInTokens = AuthTokens(
    accessToken: 'access-1',
    refreshToken: 'refresh-1',
  );

  final _routes = <String, FutureOr<http.Response> Function(http.Request)>{};
  late final MockClient _httpClient;

  /// 이 서버로 요청을 보내는 [ApiClient].
  late final ApiClient client = ApiClient(
    httpClient: _httpClient,
    baseUrl: baseUrl,
    tokenStorage: tokenStorage,
  );

  /// [method] [path] 요청에 [respond]의 응답을 돌려줍니다. 앞서 정한 응답은 덮어씁니다.
  void on(
    String method,
    String path,
    FutureOr<http.Response> Function(http.Request request) respond,
  ) {
    _routes['$method $path'] = respond;
  }

  /// [method] [path] 요청에 늘 [data]를 담은 성공 응답을 돌려줍니다.
  void onJson(String method, String path, JsonMap data, {int status = 200}) {
    on(method, path, (_) => jsonResponse(data, status: status));
  }

  /// [method] [path]로 받은 요청.
  List<http.Request> requestsTo(String method, String path) => [
    for (final request in requests)
      if (request.method == method && request.url.path == path) request,
  ];

  /// [method] [path]로 받은 마지막 요청의 JSON 본문.
  JsonMap lastBody(String method, String path) =>
      asJsonMap(jsonDecode(requestsTo(method, path).last.body));

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final respond = _routes['${request.method} ${request.url.path}'];
    if (respond == null) {
      return errorResponse(404, 'NOT_FOUND', '정하지 않은 경로');
    }
    return respond(request);
  }
}

/// [data]를 서버 형식 `{ success: true, data, error: null }`으로 감싼 성공 응답.
http.Response jsonResponse(Object? data, {int status = 200}) {
  return rawJsonResponse({
    'success': true,
    'data': data,
    'error': null,
  }, status: status);
}

/// [body]를 감싸지 않고 그대로 UTF-8 JSON으로 담은 응답.
http.Response rawJsonResponse(Object body, {int status = 200}) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

/// 본문이 없는 응답. 예: 204 No Content
http.Response emptyResponse({int status = 204}) => http.Response('', status);

/// 서버 형식 `{ success: false, data: null, error: { code, message } }`의 에러 응답.
http.Response errorResponse(int status, String code, [String message = '']) {
  return rawJsonResponse({
    'success': false,
    'data': null,
    'error': {'code': code, 'message': message},
  }, status: status);
}
