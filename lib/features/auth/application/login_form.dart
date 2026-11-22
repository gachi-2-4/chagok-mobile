import 'package:chagok_mobile/features/auth/application/auth_validators.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';

/// 로그인 화면(L01)의 입력값과 진행 상태.
class LoginForm {
  const LoginForm({
    this.phoneNumber = '',
    this.password = '',
    this.keepSignedIn = true,
    this.isSubmitting = false,
    this.failure,
  });

  /// 입력한 전화번호. 하이픈이 섞여 있을 수 있습니다.
  final String phoneNumber;

  /// 입력한 비밀번호.
  final String password;

  /// 자동 로그인 여부.
  final bool keepSignedIn;

  /// 로그인(간편 로그인 포함) 요청을 보내는 중이면 true.
  final bool isSubmitting;

  /// 마지막 로그인이 실패한 이유. 화면에서 이유에 맞는 안내를 보여 줍니다.
  final AuthFailure? failure;

  /// 하이픈 등을 뺀, 숫자만 남긴 전화번호.
  String get normalizedPhoneNumber => AuthValidators.digitsOnly(phoneNumber);

  /// 전화번호 형식이 맞고 비밀번호를 넣었으며 보내는 중이 아니면 true.
  bool get canSubmit =>
      AuthValidators.isValidPhoneNumber(phoneNumber) &&
      password.isNotEmpty &&
      !isSubmitting;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다.
  ///
  /// [failure]는 null로도 바꿀 수 있게 함수로 받습니다. 넘기지 않으면 앞선
  /// 실패를 그대로 두고, `() => null`을 넘기면 지웁니다.
  LoginForm copyWith({
    String? phoneNumber,
    String? password,
    bool? keepSignedIn,
    bool? isSubmitting,
    AuthFailure? Function()? failure,
  }) {
    return LoginForm(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      keepSignedIn: keepSignedIn ?? this.keepSignedIn,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure == null ? this.failure : failure(),
    );
  }
}
