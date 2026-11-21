import 'dart:async';
import 'dart:convert';

import 'package:chagok_mobile/core/constants/core_strings.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// 앱 전역 [ApiClient].
final apiClientProvider = Provider<ApiClient>((ref) {
  final httpClient = http.Client();
  ref.onDispose(httpClient.close);
  return ApiClient(
    httpClient: httpClient,
    baseUrl: Uri.parse(ref.watch(apiBaseUrlProvider)),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// 차곡 API 서버와 JSON을 주고받는 HTTP 클라이언트.
///
/// - 저장한 Access Token을 `Authorization: Bearer`로 붙입니다.
/// - 401 `TOKEN_EXPIRED`를 받으면 토큰을 재발급하고 원래 요청을 한 번 다시 보냅니다.
///   여러 요청이 동시에 만료돼도 재발급은 한 번만 부릅니다. 서버가 Refresh Token을
///   매번 바꾸므로(Rotation) 동시에 부르면 하나가 실패하기 때문입니다.
/// - 재발급도 401이면 토큰을 지우고 [ApiException.sessionExpiredCode]로 던집니다.
/// - 실패 응답은 서버의 `{ code, message }`를 담은 [ApiException]으로 던집니다.
class ApiClient {
  ApiClient({
    required http.Client httpClient,
    required this._baseUrl,
    required this._tokenStorage,
    this.timeout = const Duration(seconds: 30),
  }) : _http = httpClient;

  /// 목록 API가 한 번에 주는 최대 개수.
  static const maxPageSize = 50;

  /// [getAllPages]가 받는 최대 쪽수. 서버가 `hasNext`를 계속 true로 줘도 멈추게 합니다.
  static const maxPageCount = 100;

  static const _tokenExpiredCode = 'TOKEN_EXPIRED';
  static const _refreshPath = '/auth/token/refresh';

  final http.Client _http;
  final Uri _baseUrl;
  final TokenStorage _tokenStorage;

  /// 요청 하나를 기다리는 최대 시간.
  final Duration timeout;

  /// 진행 중인 토큰 재발급. 동시에 만료된 요청들이 이 재발급 하나를 함께 기다립니다.
  Future<AuthTokens>? _refreshing;

  /// GET 요청. [query]의 null 값은 빼고, 목록은 쉼표로 이어 보냅니다.
  Future<JsonMap> get(String path, {Map<String, Object?> query = const {}}) {
    return _send(() => http.Request('GET', _uri(path, query)));
  }

  /// POST 요청. 로그인 전에 부르는 API는 [isAuthenticated]를 false로 둡니다.
  Future<JsonMap> post(
    String path, {
    Object? body,
    bool isAuthenticated = true,
  }) {
    return _send(
      () => _jsonRequest('POST', path, body),
      isAuthenticated: isAuthenticated,
    );
  }

  /// PUT 요청.
  Future<JsonMap> put(String path, {Object? body}) {
    return _send(() => _jsonRequest('PUT', path, body));
  }

  /// PATCH 요청.
  Future<JsonMap> patch(String path, {Object? body}) {
    return _send(() => _jsonRequest('PATCH', path, body));
  }

  /// DELETE 요청.
  Future<JsonMap> delete(String path) {
    return _send(() => http.Request('DELETE', _uri(path)));
  }

  /// `multipart/form-data` POST 요청.
  ///
  /// 파일은 한 번만 보낼 수 있어, 토큰 재발급 뒤 다시 보낼 때를 위해 [files]는
  /// 보낼 때마다 새로 만드는 함수로 받습니다.
  Future<JsonMap> postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<http.MultipartFile> Function() files,
  }) {
    return _send(
      () => http.MultipartRequest('POST', _uri(path))
        ..fields.addAll(fields)
        ..files.addAll(files()),
    );
  }

  /// 페이지로 나뉜 목록 API의 모든 쪽을 차례로 받아 `content`를 이어 붙입니다.
  Future<List<JsonMap>> getAllPages(
    String path, {
    Map<String, Object?> query = const {},
  }) async {
    final items = <JsonMap>[];
    for (var page = 0; page < maxPageCount; page++) {
      final json = await get(
        path,
        query: {...query, 'page': page, 'size': maxPageSize},
      );
      items.addAll(json.maps('content'));
      if (!json.boolean('hasNext')) break;
    }
    return items;
  }

  Future<JsonMap> _send(
    http.BaseRequest Function() build, {
    bool isAuthenticated = true,
  }) async {
    final tokens = isAuthenticated ? await _tokenStorage.read() : null;
    var response = await _execute(build(), tokens);
    if (isAuthenticated &&
        response.statusCode == 401 &&
        _errorOf(response).code == _tokenExpiredCode) {
      final renewed = await _tokensAfterExpiry(tokens);
      response = await _execute(build(), renewed);
    }
    return _decode(response);
  }

  /// [used] 토큰이 만료됐을 때 다시 보낼 토큰.
  ///
  /// 그사이 다른 요청이 재발급을 마쳤으면 그 토큰을 쓰고, 아니면 재발급합니다.
  Future<AuthTokens> _tokensAfterExpiry(AuthTokens? used) async {
    final current = await _tokenStorage.read();
    if (current != null && current.accessToken != used?.accessToken) {
      return current;
    }
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }

  Future<AuthTokens> _refresh() async {
    final stored = await _tokenStorage.read();
    if (stored == null) throw _sessionExpired(CoreStrings.unknownError);
    final response = await _execute(
      _jsonRequest('POST', _refreshPath, {'refreshToken': stored.refreshToken}),
      null,
    );
    if (_isSuccess(response)) {
      final tokens = AuthTokens.fromJson(_decode(response));
      await _tokenStorage.save(tokens);
      return tokens;
    }
    final error = _errorOf(response);
    // 서버 오류(5xx)는 토큰이 아직 유효할 수 있으므로 지우지 않고 그대로 알립니다.
    if (response.statusCode != 401) throw error;
    await _tokenStorage.clear();
    throw _sessionExpired(error.message);
  }

  Future<http.Response> _execute(
    http.BaseRequest request,
    AuthTokens? tokens,
  ) async {
    request.headers['Accept'] = 'application/json';
    if (tokens != null) {
      request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    try {
      final streamed = await _http.send(request).timeout(timeout);
      return await http.Response.fromStream(streamed).timeout(timeout);
    } on http.ClientException catch (error) {
      throw _networkError(error);
    } on TimeoutException catch (error) {
      throw _networkError(error);
    }
  }

  http.Request _jsonRequest(String method, String path, Object? body) {
    final request = http.Request(method, _uri(path));
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }
    return request;
  }

  Uri _uri(String path, [Map<String, Object?> query = const {}]) {
    final basePath = _baseUrl.path.endsWith('/')
        ? _baseUrl.path.substring(0, _baseUrl.path.length - 1)
        : _baseUrl.path;
    final parameters = {
      for (final MapEntry(:key, :value) in query.entries)
        if (value != null)
          key: value is Iterable<Object?> ? value.join(',') : '$value',
    };
    return _baseUrl.replace(
      path: '$basePath$path',
      queryParameters: parameters.isEmpty ? null : parameters,
    );
  }

  JsonMap _decode(http.Response response) {
    if (!_isSuccess(response)) throw _errorOf(response);
    if (response.bodyBytes.isEmpty) return const {};
    return asJsonMap(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  bool _isSuccess(http.Response response) =>
      response.statusCode >= 200 && response.statusCode < 300;

  /// 실패 응답의 `{ code, message }`. 본문이 명세 형식이 아니면 상태 코드로 만듭니다.
  ApiException _errorOf(http.Response response) {
    String? code;
    String? message;
    try {
      final json = asJsonMap(jsonDecode(utf8.decode(response.bodyBytes)));
      code = json.stringOrNull('code');
      message = json.stringOrNull('message');
    } on FormatException {
      // 본문이 JSON이 아니면(게이트웨이 오류 페이지 등) 아래 기본값을 씁니다.
    }
    return ApiException(
      statusCode: response.statusCode,
      code: code ?? 'HTTP_${response.statusCode}',
      message: message ?? CoreStrings.unknownError,
    );
  }

  ApiException _sessionExpired(String message) => ApiException(
    statusCode: 401,
    code: ApiException.sessionExpiredCode,
    message: message,
  );

  ApiException _networkError(Object error) {
    debugPrint('서버에 닿지 못했습니다: $error');
    return const ApiException(
      statusCode: 0,
      code: ApiException.networkErrorCode,
      message: CoreStrings.networkError,
    );
  }
}
