import 'package:chagok_mobile/features/auth/application/auth_validators.dart';
import 'package:chagok_mobile/features/auth/application/password_reset_form.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 비밀번호 찾기 입력값.
///
/// L02~L04 화면이 차례로 쌓여 함께 보는 동안 유지하고, 흐름을 벗어나 아무 화면도
/// 보지 않으면 비웁니다. 다시 열었을 때 이전 번호로 요청하지 않게 하기 위해서입니다.
final passwordResetProvider =
    NotifierProvider.autoDispose<PasswordResetNotifier, PasswordResetForm>(
      PasswordResetNotifier.new,
    );

/// 비밀번호 찾기에서 인증번호 요청과 새 비밀번호 저장을 처리합니다.
class PasswordResetNotifier extends Notifier<PasswordResetForm> {
  @override
  PasswordResetForm build() => const PasswordResetForm();

  /// 전화번호 입력값을 바꾸고 앞선 실패 안내를 지웁니다.
  ///
  /// 번호가 바뀌면 그 번호로 받은 인증은 쓸 수 없으므로 함께 지웁니다.
  void updatePhoneNumber(String value) {
    final isChanged =
        AuthValidators.digitsOnly(value) != state.normalizedPhoneNumber;
    state = state.copyWith(
      phoneNumber: value,
      verificationToken: isChanged ? () => null : null,
      failure: () => null,
    );
  }

  /// 새 비밀번호 입력값을 바꾸고 앞선 실패 안내를 지웁니다.
  void updateNewPassword(String value) =>
      state = state.copyWith(newPassword: value, failure: () => null);

  /// 새 비밀번호 확인 입력값을 바꾸고 앞선 실패 안내를 지웁니다.
  void updateNewPasswordConfirm(String value) =>
      state = state.copyWith(newPasswordConfirm: value, failure: () => null);

  /// 입력한 전화번호로 인증번호를 보냅니다. 보냈으면 true.
  ///
  /// 보낸 번호를 [PasswordResetForm.codeSentTo]에 남겨, 요청하는 사이 입력이 바뀌어도
  /// 인증 화면은 실제로 보낸 번호로 인증합니다. 앞선 인증은 버립니다.
  Future<bool> requestVerificationCode() async {
    if (!state.canRequestCode) return false;
    final phoneNumber = state.normalizedPhoneNumber;
    state = state.copyWith(verificationToken: () => null);
    final isSent = await _run(
      () => ref.read(authRepositoryProvider).sendVerificationCode(phoneNumber),
    );
    if (isSent && ref.mounted) {
      state = state.copyWith(codeSentTo: () => phoneNumber);
    }
    return isSent;
  }

  /// 인증 화면에서 받은 증명 값을 남깁니다. 계정 요청에 함께 넘깁니다.
  void markVerified(String verificationToken) =>
      state = state.copyWith(verificationToken: () => verificationToken);

  /// 인증을 마친 번호의 새 비밀번호를 저장합니다. 저장했으면 true.
  Future<bool> reset() async {
    final form = state;
    final token = form.verificationToken;
    if (!form.canReset || token == null) return false;
    return _run(
      () => ref
          .read(authRepositoryProvider)
          .resetPassword(
            phoneNumber: form.normalizedPhoneNumber,
            newPassword: form.newPassword,
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
