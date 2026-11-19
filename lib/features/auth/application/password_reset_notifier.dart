import 'package:chagok_mobile/features/auth/application/password_reset_form.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart';
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

  /// 전화번호 입력값을 바꾸고 앞선 실패 안내를 지웁니다.
  void updatePhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value, failure: () => null);

  /// 새 비밀번호 입력값을 바꾸고 앞선 실패 안내를 지웁니다.
  void updateNewPassword(String value) =>
      state = state.copyWith(newPassword: value, failure: () => null);

  /// 새 비밀번호 확인 입력값을 바꾸고 앞선 실패 안내를 지웁니다.
  void updateNewPasswordConfirm(String value) =>
      state = state.copyWith(newPasswordConfirm: value, failure: () => null);

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
