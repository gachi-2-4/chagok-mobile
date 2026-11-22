import 'package:chagok_mobile/features/auth/application/auth_validators.dart';
import 'package:chagok_mobile/features/auth/application/sign_up_form.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/sent_verification_code.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:chagok_mobile/features/auth/data/verification_purpose.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 회원가입 입력값.
///
/// A01~A03 화면이 차례로 쌓여 함께 보는 동안 유지하고, 가입 흐름을 벗어나
/// 아무 화면도 보지 않으면 비웁니다. 다시 열었을 때 빈 입력창 뒤에 이전 값이
/// 남아 그 값으로 진행되지 않게 하기 위해서입니다.
final signUpProvider = NotifierProvider.autoDispose<SignUpNotifier, SignUpForm>(
  SignUpNotifier.new,
);

/// 회원가입 입력값을 받고, 인증번호 요청과 가입 완료를 처리합니다.
class SignUpNotifier extends Notifier<SignUpForm> {
  @override
  SignUpForm build() => const SignUpForm();

  /// 전화번호 입력값을 바꿉니다.
  ///
  /// 번호가 바뀌면 그 번호로 받은 인증은 쓸 수 없으므로 함께 지웁니다.
  void updatePhoneNumber(String value) {
    final isChanged =
        AuthValidators.digitsOnly(value) != state.normalizedPhoneNumber;
    state = state.copyWith(
      phoneNumber: value,
      verificationToken: isChanged ? () => null : null,
    );
  }

  /// 이름 입력값을 바꿉니다.
  void updateName(String value) => state = state.copyWith(name: value);

  /// 생년월일 입력값을 바꿉니다.
  void updateBirthDate(String value) =>
      state = state.copyWith(birthDate: value);

  /// 비밀번호 입력값을 바꿉니다.
  void updatePassword(String value) => state = state.copyWith(password: value);

  /// 비밀번호 확인 입력값을 바꿉니다.
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
  ///
  /// 보낸 번호와 결과를 [SignUpForm.codeSentTo]·[SignUpForm.sentCode]에 남겨,
  /// 요청하는 사이 입력이 바뀌어도 인증 화면은 실제로 보낸 번호로 인증합니다.
  /// 앞선 인증은 버립니다.
  Future<bool> requestVerificationCode() async {
    if (!state.canRequestCode) return false;
    final phoneNumber = state.normalizedPhoneNumber;
    state = state.copyWith(verificationToken: () => null);
    SentVerificationCode? sentCode;
    final isSent = await _run(() async {
      sentCode = await ref
          .read(authRepositoryProvider)
          .sendVerificationCode(
            phoneNumber,
            purpose: VerificationPurpose.signUp,
          );
    });
    if (isSent && ref.mounted) {
      state = state.copyWith(codeSentTo: () => phoneNumber, sentCode: sentCode);
    }
    return isSent;
  }

  /// 인증 화면에서 받은 증명 값을 남깁니다. 계정 요청에 함께 넘깁니다.
  void markVerified(String verificationToken) =>
      state = state.copyWith(verificationToken: () => verificationToken);

  /// 약관 동의를 마치고 계정을 만듭니다. 만들었으면 true.
  Future<bool> complete() async {
    final form = state;
    final token = form.verificationToken;
    if (!form.canComplete || token == null) return false;
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .signUp(
            phoneNumber: form.normalizedPhoneNumber,
            name: form.name.trim(),
            birthDate: AuthValidators.digitsOnly(form.birthDate),
            password: form.password,
            agreedToMarketing: form.agreedTerms.contains(Term.marketing),
            verificationToken: token,
          ),
    );
  }

  /// [request]를 보내는 동안 보내는 중으로 표시하고, 실패하면 이유를 남깁니다.
  ///
  /// [AuthException]이 아닌 예외(네트워크 오류 등)도 잡아 [AuthFailure.unknown]으로
  /// 남겨, 보내는 중 상태로 멈추지 않게 합니다.
  Future<bool> _run(Future<void> Function() request) async {
    state = state.copyWith(isSubmitting: true, failure: () => null);
    try {
      await request();
      if (ref.mounted) state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error, stackTrace) {
      final failure = switch (error) {
        AuthException(:final failure) => failure,
        _ => AuthFailure.unknown,
      };
      if (failure == AuthFailure.unknown) {
        debugPrint('계정 요청을 처리하지 못했습니다: $error\n$stackTrace');
      }
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false, failure: () => failure);
      }
      return false;
    }
  }
}
