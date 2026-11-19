import 'package:chagok_mobile/features/auth/application/auth_validators.dart';
import 'package:chagok_mobile/features/auth/application/sign_up_form.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 회원가입 입력값. A01~A03 화면이 함께 쓰므로 화면을 벗어나도 유지합니다.
final signUpProvider = NotifierProvider<SignUpNotifier, SignUpForm>(
  SignUpNotifier.new,
);

/// 회원가입 입력값을 받고, 인증번호 요청과 가입 완료를 처리합니다.
class SignUpNotifier extends Notifier<SignUpForm> {
  @override
  SignUpForm build() => const SignUpForm();

  void updatePhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value);

  void updateName(String value) => state = state.copyWith(name: value);

  void updateBirthDate(String value) =>
      state = state.copyWith(birthDate: value);

  void updatePassword(String value) => state = state.copyWith(password: value);

  void updatePasswordConfirm(String value) =>
      state = state.copyWith(passwordConfirm: value);

  /// 약관 하나의 동의 여부를 바꿉니다.
  void toggleTerm(Term term) {
    final agreed = {...state.agreedTerms};
    if (!agreed.remove(term)) agreed.add(term);
    state = state.copyWith(agreedTerms: agreed);
  }

  /// 모두 동의했으면 모두 해제하고, 아니면 모두 동의합니다.
  void toggleAllTerms() {
    state = state.copyWith(
      agreedTerms: state.hasAgreedToAll ? const {} : Term.values.toSet(),
    );
  }

  /// 입력한 전화번호로 인증번호를 보냅니다. 보냈으면 true.
  Future<bool> requestVerificationCode() async {
    if (!state.canRequestCode) return false;
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .sendVerificationCode(state.normalizedPhoneNumber),
    );
  }

  /// 약관 동의를 마치고 계정을 만듭니다. 만들었으면 true.
  Future<bool> complete() async {
    if (!state.canComplete) return false;
    final form = state;
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .signUp(
            phoneNumber: form.normalizedPhoneNumber,
            name: form.name.trim(),
            birthDate: AuthValidators.digitsOnly(form.birthDate),
            password: form.password,
            agreedToMarketing: form.agreedTerms.contains(Term.marketing),
          ),
    );
  }

  Future<bool> _run(Future<void> Function() request) async {
    state = state.copyWith(isSubmitting: true, errorMessage: () => null);
    try {
      await request();
      state = state.copyWith(isSubmitting: false);
      return true;
    } on AuthException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: () => error.message,
      );
      return false;
    }
  }
}
