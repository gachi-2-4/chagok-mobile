/// 서버가 실패로 응답했거나 서버에 닿지 못했을 때 던지는 예외.
///
/// 서버 에러 응답 `{ "code": ..., "message": ... }`를 그대로 담습니다.
/// [message]는 서버가 화면에 그대로 띄울 수 있게 만든 문장입니다.
class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  /// 서버에 닿지 못했을 때(네트워크 끊김·시간 초과)의 [code].
  static const networkErrorCode = 'NETWORK_ERROR';

  /// 토큰 재발급까지 실패해 다시 로그인해야 할 때의 [code]. L04 화면으로 갑니다.
  static const sessionExpiredCode = 'SESSION_EXPIRED';

  /// HTTP 상태 코드. 서버에 닿지 못했으면 0.
  final int statusCode;

  /// 서버가 준 에러 코드. 예: `DOCUMENT_NOT_FOUND`
  final String code;

  /// 사용자에게 보여 줄 수 있는 문장.
  final String message;

  /// 없는 리소스(404)이면 true. 다른 사용자의 리소스도 서버는 404로 줍니다.
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode $code): $message';
}
