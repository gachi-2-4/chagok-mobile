import 'package:chagok_mobile/features/auth/application/login_form.dart';
import 'package:chagok_mobile/features/auth/application/social_login_step.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인 입력값. 화면을 벗어나면 비웁니다.
final loginProvider = NotifierProvider.autoDispose<LoginNotifier, LoginForm>(
  LoginNotifier.new,
);

/// 로그인 입력값을 받고 로그인을 처리합니다.
class LoginNotifier extends Notifier<LoginForm> {
  @override
  LoginForm build() => const LoginForm();

  /// 전화번호 입력값을 바꾸고 앞선 실패 안내를 지웁니다.
  void updatePhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value, failure: () => null);

  /// 비밀번호 입력값을 바꾸고 앞선 실패 안내를 지웁니다.
  void updatePassword(String value) =>
      state = state.copyWith(password: value, failure: () => null);

  /// 자동 로그인을 켜거나 끕니다.
  void toggleKeepSignedIn() =>
      state = state.copyWith(keepSignedIn: !state.keepSignedIn);

  /// 로그인합니다. 성공하면 true.
  Future<bool> logIn() async {
    if (!state.canSubmit) return false;
    final form = state;
    final isLoggedIn = await _submit(
      () => ref
          .read(authRepositoryProvider)
          .logIn(
            phoneNumber: form.normalizedPhoneNumber,
            password: form.password,
            keepSignedIn: form.keepSignedIn,
          )
          .then((_) => true),
    );
    return isLoggedIn ?? false;
  }

  /// 카카오로 로그인하고 이어 갈 단계를 돌려줍니다.
  ///
  /// 사용자가 카카오 로그인을 취소했거나 실패하면 null입니다. 실패 이유는
  /// [LoginForm.failure]에 남깁니다.
  Future<SocialLoginStep?> logInWithKakao() async {
    if (state.isSubmitting) return null;
    final keepSignedIn = state.keepSignedIn;
    final result = await _submit(
      () => ref
          .read(authRepositoryProvider)
          .logInWithKakao(keepSignedIn: keepSignedIn),
    );
    return result == null ? null : SocialLoginStep.after(result);
  }

  /// [request]를 보내는 동안 보내는 중으로 표시하고, 실패하면 이유를 남깁니다.
  ///
  /// [AuthException]이 아닌 예외도 잡아 보내는 중 상태로 멈추지 않게 합니다.
  /// 실패하면 null입니다.
  Future<T?> _submit<T>(Future<T?> Function() request) async {
    state = state.copyWith(isSubmitting: true, failure: () => null);
    try {
      final result = await request();
      if (ref.mounted) state = state.copyWith(isSubmitting: false);
      return result;
    } catch (error, stackTrace) {
      final failure = switch (error) {
        AuthException(:final failure) => failure,
        _ => AuthFailure.unknown,
      };
      if (failure == AuthFailure.unknown) {
        debugPrint('로그인하지 못했습니다: $error\n$stackTrace');
      }
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false, failure: () => failure);
      }
      return null;
    }
  }
}
