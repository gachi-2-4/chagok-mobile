import 'package:chagok_mobile/features/auth/application/login_form.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인 입력값. 화면을 벗어나면 비웁니다.
final loginProvider = NotifierProvider.autoDispose<LoginNotifier, LoginForm>(
  LoginNotifier.new,
);

/// 로그인 입력값을 받고 로그인을 처리합니다.
class LoginNotifier extends Notifier<LoginForm> {
  @override
  LoginForm build() => const LoginForm();

  void updatePhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value, errorMessage: () => null);

  void updatePassword(String value) =>
      state = state.copyWith(password: value, errorMessage: () => null);

  void toggleKeepSignedIn() =>
      state = state.copyWith(keepSignedIn: !state.keepSignedIn);

  /// 로그인합니다. 성공하면 true.
  Future<bool> logIn() async {
    if (!state.canSubmit) return false;
    final form = state;
    state = state.copyWith(isSubmitting: true, errorMessage: () => null);
    try {
      await ref
          .read(authRepositoryProvider)
          .logIn(
            phoneNumber: form.normalizedPhoneNumber,
            password: form.password,
            keepSignedIn: form.keepSignedIn,
          );
      if (ref.mounted) state = state.copyWith(isSubmitting: false);
      return true;
    } on AuthException catch (error) {
      if (ref.mounted) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: () => error.message,
        );
      }
      return false;
    }
  }
}
