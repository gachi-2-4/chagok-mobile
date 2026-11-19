import 'dart:async';

import 'package:chagok_mobile/features/auth/application/phone_verification_state.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 전화번호 하나에 대한 인증 상태. 화면을 벗어나면 타이머와 함께 정리합니다.
final phoneVerificationProvider = NotifierProvider.autoDispose
    .family<PhoneVerificationNotifier, PhoneVerificationState, String>(
      PhoneVerificationNotifier.new,
    );

/// 인증번호 입력, 남은 시간, 다시 받기, 확인을 처리합니다.
///
/// 인증번호는 이 화면에 오기 전에 이미 보냈다고 보고 타이머만 시작합니다.
class PhoneVerificationNotifier extends Notifier<PhoneVerificationState> {
  PhoneVerificationNotifier(this.phoneNumber);

  /// 숫자만 남긴 전화번호.
  final String phoneNumber;

  /// 인증번호가 유효한 시간(초).
  static const codeLifetimeSeconds = 180;

  Timer? _timer;

  @override
  PhoneVerificationState build() {
    ref.onDispose(() => _timer?.cancel());
    _startTimer();
    return const PhoneVerificationState(remainingSeconds: codeLifetimeSeconds);
  }

  /// 입력칸의 값을 받습니다. 숫자가 아닌 글자와 넘치는 자리는 버립니다.
  void updateCode(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final code = digits.length > PhoneVerificationState.codeLength
        ? digits.substring(0, PhoneVerificationState.codeLength)
        : digits;
    state = state.copyWith(code: code, failure: () => null);
  }

  /// 인증번호를 다시 보내고 남은 시간을 처음으로 돌립니다. 보냈으면 true.
  ///
  /// 보내지 못하면 남은 시간은 그대로 두고 [AuthFailure.unknown]을 남깁니다.
  Future<bool> resend() async {
    try {
      await ref.read(authRepositoryProvider).sendVerificationCode(phoneNumber);
    } catch (error, stackTrace) {
      debugPrint('인증번호를 다시 보내지 못했습니다: $error\n$stackTrace');
      if (ref.mounted) {
        state = state.copyWith(failure: () => AuthFailure.unknown);
      }
      return false;
    }
    if (!ref.mounted) return true;
    state = const PhoneVerificationState(remainingSeconds: codeLifetimeSeconds);
    _startTimer();
    return true;
  }

  /// 입력한 인증번호를 확인합니다. 맞으면 true.
  ///
  /// 틀리면 [AuthFailure.codeMismatch], 확인하지 못하면 [AuthFailure.unknown]을 남깁니다.
  Future<bool> verify() async {
    if (!state.canVerify) return false;
    state = state.copyWith(isSubmitting: true, failure: () => null);
    bool isVerified;
    AuthFailure? failure;
    try {
      isVerified = await ref
          .read(authRepositoryProvider)
          .verifyCode(phoneNumber: phoneNumber, code: state.code);
      if (!isVerified) failure = AuthFailure.codeMismatch;
    } catch (error, stackTrace) {
      debugPrint('인증번호를 확인하지 못했습니다: $error\n$stackTrace');
      isVerified = false;
      failure = AuthFailure.unknown;
    }
    if (!ref.mounted) return isVerified;
    state = state.copyWith(isSubmitting: false, failure: () => failure);
    if (isVerified) _timer?.cancel();
    return isVerified;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.remainingSeconds - 1;
      state = state.copyWith(remainingSeconds: remaining);
      if (remaining <= 0) timer.cancel();
    });
  }
}
