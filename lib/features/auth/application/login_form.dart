import 'package:chagok_mobile/features/auth/application/auth_validators.dart';

/// 로그인 화면(L01)의 입력값과 진행 상태.
class LoginForm {
  const LoginForm({
    this.phoneNumber = '',
    this.password = '',
    this.keepSignedIn = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String phoneNumber;
  final String password;

  /// 자동 로그인 여부.
  final bool keepSignedIn;

  final bool isSubmitting;

  /// 마지막 로그인이 실패한 이유. 사용자에게 보여 줍니다.
  final String? errorMessage;

  /// 하이픈 등을 뺀, 숫자만 남긴 전화번호.
  String get normalizedPhoneNumber => AuthValidators.digitsOnly(phoneNumber);

  bool get canSubmit =>
      AuthValidators.isValidPhoneNumber(phoneNumber) &&
      password.isNotEmpty &&
      !isSubmitting;

  LoginForm copyWith({
    String? phoneNumber,
    String? password,
    bool? keepSignedIn,
    bool? isSubmitting,
    String? Function()? errorMessage,
  }) {
    return LoginForm(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      keepSignedIn: keepSignedIn ?? this.keepSignedIn,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
    );
  }
}
