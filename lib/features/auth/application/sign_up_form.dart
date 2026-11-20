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
    this.codeSentTo,
    this.verificationToken,
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

  /// 인증번호를 보낸 번호(숫자만). 요청하는 사이 입력을 바꿔도 이 번호로 인증합니다.
  final String? codeSentTo;

  /// 인증번호를 확인하고 받은 증명 값. 계정 요청에 함께 넘깁니다.
  final String? verificationToken;

  /// 요청을 보내는 중이면 true.
  final bool isSubmitting;

  /// 마지막 요청이 실패한 이유. 화면에서 이유에 맞는 안내를 보여 줍니다.
  final AuthFailure? failure;

  /// 하이픈 등을 뺀, 숫자만 남긴 전화번호.
  String get normalizedPhoneNumber => AuthValidators.digitsOnly(phoneNumber);

  /// 지금 입력한 번호로 인증을 마쳤으면 true.
  bool get isVerified =>
      verificationToken != null && codeSentTo == normalizedPhoneNumber;

  /// 비밀번호가 비밀번호 규칙에 맞으면 true.
  bool get isPasswordValid => AuthValidators.isValidPassword(password);

  /// 비밀번호 확인 칸을 채웠는데 비밀번호와 다르면 true.
  bool get hasPasswordMismatch =>
      passwordConfirm.isNotEmpty && passwordConfirm != password;

  /// 정보 입력(A01)의 모든 칸을 규칙에 맞게 채웠으면 true.
  bool get hasValidDetails =>
      AuthValidators.isValidPhoneNumber(phoneNumber) &&
      name.trim().isNotEmpty &&
      AuthValidators.isValidBirthDate(birthDate) &&
      isPasswordValid &&
      passwordConfirm == password;

  /// 정보 입력(A01)을 마치고 인증번호를 받을 수 있으면 true.
  bool get canRequestCode => hasValidDetails && !isSubmitting;

  /// 모든 약관에 동의했으면 true.
  bool get hasAgreedToAll => agreedTerms.length == Term.values.length;

  /// 가입 정보를 채우고 인증을 마쳤으며 필수 약관에 모두 동의해 가입할 수 있으면 true.
  ///
  /// 약관 화면 주소로 바로 들어와도 빈 정보나 인증 없이 가입하지 못하게 합니다.
  bool get canComplete =>
      hasValidDetails &&
      isVerified &&
      Term.values
          .where((term) => term.isRequired)
          .every(agreedTerms.contains) &&
      !isSubmitting;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다.
  ///
  /// [codeSentTo]·[verificationToken]·[failure]는 null로도 바꿀 수 있게 함수로
  /// 받습니다. 넘기지 않으면 앞선 값을 그대로 두고, `() => null`을 넘기면 지웁니다.
  SignUpForm copyWith({
    String? phoneNumber,
    String? name,
    String? birthDate,
    String? password,
    String? passwordConfirm,
    Set<Term>? agreedTerms,
    String? Function()? codeSentTo,
    String? Function()? verificationToken,
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
      codeSentTo: codeSentTo == null ? this.codeSentTo : codeSentTo(),
      verificationToken: verificationToken == null
          ? this.verificationToken
          : verificationToken(),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: failure == null ? this.failure : failure(),
    );
  }
}
