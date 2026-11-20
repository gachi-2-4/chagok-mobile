import 'package:chagok_mobile/features/auth/data/auth_failure.dart';

/// 전화번호 인증 화면(A02, L04)의 상태.
class PhoneVerificationState {
  const PhoneVerificationState({
    required this.remainingSeconds,
    this.code = '',
    this.isSubmitting = false,
    this.failure,
  });

  /// 인증번호 자릿수.
  static const codeLength = 6;

  /// 지금까지 입력한 인증번호.
  final String code;

  /// 인증번호가 만료되기까지 남은 시간(초).
  final int remainingSeconds;

  /// 인증번호를 확인하는 중이면 true.
  final bool isSubmitting;

  /// 마지막 확인이 실패한 이유. 화면에서 이유에 맞는 안내를 보여 줍니다.
  final AuthFailure? failure;

  /// 남은 시간이 다 지났으면 true.
  bool get isExpired => remainingSeconds <= 0;

  /// 인증번호를 다 입력했고 아직 만료되지 않았으면 true.
  bool get canVerify =>
      code.length == codeLength && !isExpired && !isSubmitting;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다.
  ///
  /// [failure]는 null로도 바꿀 수 있게 함수로 받습니다. 넘기지 않으면 앞선
  /// 실패를 그대로 두고, `() => null`을 넘기면 지웁니다.
  PhoneVerificationState copyWith({
    String? code,
    int? remainingSeconds,
    bool? isSubmitting,
    AuthFailure? Function()? failure,
  }) {
    return PhoneVerificationState(
      code: code ?? this.code,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure == null ? this.failure : failure(),
    );
  }
}
