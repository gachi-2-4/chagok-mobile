import 'dart:async';
import 'dart:math';

import 'package:chagok_mobile/features/auth/application/auth_clock.dart';
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

  /// 지금 인증번호가 만료되는 시각.
  late DateTime _expiresAt;

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
  /// 확인하는 중이면 보내지 않습니다. 확인 결과가 새 타이머·상태를 덮지 않게 하기 위해서입니다.
  Future<bool> resend() async {
    if (state.isSubmitting) return false;
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

  /// 입력한 인증번호를 확인합니다. 맞으면 인증 증명 값을, 아니면 null을 돌려줍니다.
  ///
  /// 틀리면 [AuthFailure.codeMismatch], 확인하지 못하면 [AuthFailure.unknown]을 남깁니다.
  /// 확인에 성공해도 타이머는 멈추지 않아, 뒤로 돌아오면 실제 남은 시간을 보여 줍니다.
  Future<String?> verify() async {
    // Timer 콜백이 밀렸어도 만료된 인증번호를 보내지 않도록 먼저 시각을 맞춥니다.
    _syncRemaining();
    if (!state.canVerify) return null;
    state = state.copyWith(isSubmitting: true, failure: () => null);
    String? token;
    AuthFailure? failure;
    try {
      token = await ref
          .read(authRepositoryProvider)
          .verifyCode(phoneNumber: phoneNumber, code: state.code);
      if (token == null) failure = AuthFailure.codeMismatch;
    } catch (error, stackTrace) {
      debugPrint('인증번호를 확인하지 못했습니다: $error\n$stackTrace');
      failure = AuthFailure.unknown;
    }
    if (ref.mounted) {
      state = state.copyWith(isSubmitting: false, failure: () => failure);
    }
    return token;
  }

  /// 만료 시각을 지금부터 [codeLifetimeSeconds] 뒤로 잡고 1초마다 남은 시간을 맞춥니다.
  ///
  /// 주기 Timer는 밀린 콜백을 모두 부르지 않으므로, 콜백 횟수를 세지 않고
  /// 만료 시각과 지금 시각의 차이로 남은 시간을 계산합니다.
  void _startTimer() {
    _timer?.cancel();
    _expiresAt = ref
        .read(authClockProvider)()
        .add(const Duration(seconds: codeLifetimeSeconds));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _syncRemaining();
      if (state.isExpired) timer.cancel();
    });
  }

  void _syncRemaining() {
    final left = _expiresAt.difference(ref.read(authClockProvider)());
    final remaining = max(0, (left.inMilliseconds / 1000).ceil());
    if (remaining != state.remainingSeconds) {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }
}
