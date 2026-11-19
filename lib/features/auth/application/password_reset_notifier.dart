import 'package:chagok_mobile/features/auth/application/password_reset_form.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 비밀번호 찾기 입력값. L02~L04 화면이 함께 쓰므로 화면을 벗어나도 유지합니다.
final passwordResetProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetForm>(
      PasswordResetNotifier.new,
    );

/// 비밀번호 찾기에서 인증번호 요청과 새 비밀번호 저장을 처리합니다.
class PasswordResetNotifier extends Notifier<PasswordResetForm> {
  @override
  PasswordResetForm build() => const PasswordResetForm();

  void updatePhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value, errorMessage: () => null);

  void updateNewPassword(String value) =>
      state = state.copyWith(newPassword: value, errorMessage: () => null);

  void updateNewPasswordConfirm(String value) => state = state.copyWith(
    newPasswordConfirm: value,
    errorMessage: () => null,
  );

  /// 입력한 전화번호로 인증번호를 보냅니다. 보냈으면 true.
  Future<bool> requestVerificationCode() async {
    if (!state.canRequestCode) return false;
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .sendVerificationCode(state.normalizedPhoneNumber),
    );
  }

  /// 새 비밀번호를 저장합니다. 저장했으면 true.
  Future<bool> reset() async {
    if (!state.canReset) return false;
    final form = state;
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .resetPassword(
            phoneNumber: form.normalizedPhoneNumber,
            newPassword: form.newPassword,
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
