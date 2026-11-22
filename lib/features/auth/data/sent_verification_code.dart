import 'package:chagok_mobile/core/network/json_map.dart';

/// 인증번호를 보낸 결과. 남은 시간과 다시 받기까지 기다릴 시간을 정합니다.
class SentVerificationCode {
  const SentVerificationCode({
    this.expiresIn = defaultExpiresIn,
    this.resendAvailableIn = 0,
    this.code,
  });

  /// 서버 응답의 `data`에서 읽습니다.
  ///
  /// 비밀번호 재설정 요청처럼 값을 주지 않는 응답도 있어, 없는 값은 기본값으로 둡니다.
  factory SentVerificationCode.fromJson(JsonMap json) {
    return SentVerificationCode(
      expiresIn: json.integerOrNull('expiresIn') ?? defaultExpiresIn,
      resendAvailableIn: json.integerOrNull('resendAvailableIn') ?? 0,
      code: json.stringOrNull('code'),
    );
  }

  /// 서버가 유효 시간을 알려 주지 않을 때 쓰는 인증번호 유효 시간(초).
  static const defaultExpiresIn = 180;

  /// 인증번호가 유효한 시간(초).
  final int expiresIn;

  /// 인증번호를 다시 받을 수 있기까지 남은 시간(초).
  final int resendAvailableIn;

  /// 보낸 인증번호. 문자를 보내지 않는 개발 서버만 알려 주고, 그 밖에는 null입니다.
  final String? code;

  @override
  bool operator ==(Object other) =>
      other is SentVerificationCode &&
      other.expiresIn == expiresIn &&
      other.resendAvailableIn == resendAvailableIn &&
      other.code == code;

  @override
  int get hashCode => Object.hash(expiresIn, resendAvailableIn, code);
}
