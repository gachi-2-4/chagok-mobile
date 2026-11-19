import 'package:chagok_mobile/features/auth/application/auth_validators.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';

/// 회원가입 화면(A01~A03)에서 입력한 값과 진행 상태.
class SignUpForm {
  const SignUpForm({
    this.phoneNumber = '',
    this.name = '',
    this.birthDate = '',
    this.password = '',
    this.passwordConfirm = '',
    this.agreedTerms = const {},
    this.isSubmitting = false,
    this.failure,
  });

  /// 입력한 전화번호. 하이픈이 섞여 있을 수 있습니다.
  final String phoneNumber;

  /// 이름.
  final String name;

  /// 생년월일. 예: "1990.01.01"
  final String birthDate;

  /// 비밀번호.
  final String password;

  /// 비밀번호 확인 칸.
  final String passwordConfirm;

  /// 동의한 약관.
  final Set<Term> agreedTerms;

  /// 요청을 보내는 중이면 true.
  final bool isSubmitting;

  /// 마지막 요청이 실패한 이유. 화면에서 이유에 맞는 안내를 보여 줍니다.
  final AuthFailure? failure;

  /// 하이픈 등을 뺀, 숫자만 남긴 전화번호.
  String get normalizedPhoneNumber => AuthValidators.digitsOnly(phoneNumber);

  /// 비밀번호가 비밀번호 규칙에 맞으면 true.
  bool get isPasswordValid => AuthValidators.isValidPassword(password);

  /// 비밀번호 확인 칸을 채웠는데 비밀번호와 다르면 true.
  bool get hasPasswordMismatch =>
      passwordConfirm.isNotEmpty && passwordConfirm != password;

  /// 정보 입력(A01)을 마치고 인증번호를 받을 수 있으면 true.
  bool get canRequestCode =>
      AuthValidators.isValidPhoneNumber(phoneNumber) &&
      name.trim().isNotEmpty &&
      AuthValidators.isValidBirthDate(birthDate) &&
      isPasswordValid &&
      passwordConfirm == password &&
      !isSubmitting;

  /// 모든 약관에 동의했으면 true.
  bool get hasAgreedToAll => agreedTerms.length == Term.values.length;

  /// 필수 약관에 모두 동의해 가입할 수 있으면 true.
  bool get canComplete =>
      Term.values
          .where((term) => term.isRequired)
          .every(agreedTerms.contains) &&
      !isSubmitting;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다. [failure]는 null로도 바꿀 수 있게 함수로 받습니다.
  SignUpForm copyWith({
    String? phoneNumber,
    String? name,
    String? birthDate,
    String? password,
    String? passwordConfirm,
    Set<Term>? agreedTerms,
    bool? isSubmitting,
    AuthFailure? Function()? failure,
  }) {
    return SignUpForm(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      agreedTerms: agreedTerms ?? this.agreedTerms,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure == null ? this.failure : failure(),
    );
  }
}
