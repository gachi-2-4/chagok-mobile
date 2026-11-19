/// 전화번호 인증 화면(A02, L04)의 상태.
class PhoneVerificationState {
  const PhoneVerificationState({
    required this.remainingSeconds,
    this.code = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// 인증번호 자릿수.
  static const codeLength = 6;

  /// 지금까지 입력한 인증번호.
  final String code;

  /// 인증번호가 만료되기까지 남은 시간(초).
  final int remainingSeconds;

  final bool isSubmitting;

  /// 마지막 확인이 실패한 이유. 사용자에게 보여 줍니다.
  final String? errorMessage;

  bool get isExpired => remainingSeconds <= 0;

  /// 인증번호를 다 입력했고 아직 만료되지 않았으면 true.
  bool get canVerify =>
      code.length == codeLength && !isExpired && !isSubmitting;

  PhoneVerificationState copyWith({
    String? code,
    int? remainingSeconds,
    bool? isSubmitting,
    String? Function()? errorMessage,
  }) {
    return PhoneVerificationState(
      code: code ?? this.code,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
    );
  }
}
