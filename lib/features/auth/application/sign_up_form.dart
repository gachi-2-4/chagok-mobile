import 'package:chagok_mobile/features/auth/application/auth_validators.dart';
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
    this.errorMessage,
  });

  final String phoneNumber;
  final String name;
  final String birthDate;
  final String password;
  final String passwordConfirm;
  final Set<Term> agreedTerms;
  final bool isSubmitting;

  /// 마지막 요청이 실패한 이유. 사용자에게 보여 줍니다.
  final String? errorMessage;

  /// 하이픈 등을 뺀, 숫자만 남긴 전화번호.
  String get normalizedPhoneNumber => AuthValidators.digitsOnly(phoneNumber);

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

  bool get hasAgreedToAll => agreedTerms.length == Term.values.length;

  /// 필수 약관에 모두 동의해 가입할 수 있으면 true.
  bool get canComplete =>
      Term.values
          .where((term) => term.isRequired)
          .every(agreedTerms.contains) &&
      !isSubmitting;

  SignUpForm copyWith({
    String? phoneNumber,
    String? name,
    String? birthDate,
    String? password,
    String? passwordConfirm,
    Set<Term>? agreedTerms,
    bool? isSubmitting,
    String? Function()? errorMessage,
  }) {
    return SignUpForm(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      agreedTerms: agreedTerms ?? this.agreedTerms,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
    );
  }
}
