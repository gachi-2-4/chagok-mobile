import 'dart:async';
import 'dart:math';

import 'package:chagok_mobile/features/auth/application/auth_clock.dart';
import 'package:chagok_mobile/features/auth/application/phone_verification_state.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/sent_verification_code.dart';
import 'package:chagok_mobile/features/auth/data/verification_purpose.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 인증할 전화번호(숫자만)와 인증 목적, 이 화면에 오기 전에 인증번호를 보낸 결과.
///
/// 회원가입과 비밀번호 재설정은 서버에서 인증번호를 보내고 확인하는 방식이 달라,
/// 같은 번호라도 목적마다 따로 인증합니다. 앞 화면에서 인증번호를 다시 요청하면
/// 보낸 결과가 바뀌어 새 인증으로 시작합니다.
typedef PhoneVerificationTarget = ({
  String phoneNumber,
  VerificationPurpose purpose,
  SentVerificationCode sentCode,
});

/// 전화번호 하나에 대한 인증 상태. 화면을 벗어나면 타이머와 함께 정리합니다.
final phoneVerificationProvider = NotifierProvider.autoDispose
    .family<
      PhoneVerificationNotifier,
      PhoneVerificationState,
      PhoneVerificationTarget
    >(PhoneVerificationNotifier.new);

/// 인증번호 입력, 남은 시간, 다시 받기, 확인을 처리합니다.
///
/// 인증번호는 이 화면에 오기 전에 이미 보냈다고 보고, 보낸 결과로 타이머만 시작합니다.
/// 개발 서버가 인증번호를 알려 주면 입력칸에 미리 채웁니다.
class PhoneVerificationNotifier extends Notifier<PhoneVerificationState> {
  PhoneVerificationNotifier(this.target);

  /// 인증할 전화번호와 목적.
  final PhoneVerificationTarget target;

  /// 숫자만 남긴 전화번호.
  String get phoneNumber => target.phoneNumber;

  Timer? _timer;

  /// 인증번호를 다시 보내는 중이면 true.
  ///
  /// 화면에 보여 줄 값이 아니라 두 요청이 겹치지 않게 막는 표시라 상태에 두지 않습니다.
  bool _isResending = false;

  /// 지금 인증번호가 만료되는 시각.
  late DateTime _expiresAt;

  /// 인증번호를 다시 받을 수 있게 되는 시각.
  late DateTime _resendAvailableAt;

  /// 지금 시각을 돌려주는 함수. 만료 시각과 남은 시간을 같은 시계로 계산합니다.
  late DateTime Function() _now;

  @override
  PhoneVerificationState build() {
    ref.onDispose(() => _timer?.cancel());
    _now = ref.watch(authClockProvider);
    return _start(target.sentCode);
  }

  /// 입력칸의 값을 받습니다. 숫자가 아닌 글자와 넘치는 자리는 버립니다.
  void updateCode(String value) {
    state = state.copyWith(code: _codeDigits(value), failure: () => null);
  }

  /// 인증번호를 다시 보내고, 서버가 준 시간으로 남은 시간을 처음부터 셉니다. 보냈으면 true.
  ///
  /// 보내지 못하면 남은 시간은 그대로 두고 [AuthFailure.unknown]을 남깁니다.
  /// 다시 받기 대기 시간이 남았으면 서버가 거절하므로 보내지 않습니다.
  /// 확인하는 중이거나 이미 다시 보내는 중이어도 보내지 않습니다. 확인 결과가 새 타이머·상태를
  /// 덮지 않게 하기 위해서입니다. 다시 보내는 동안에는 [verify]도 막습니다.
  Future<bool> resend() async {
    // Timer 콜백이 밀렸어도 대기 시간이 지났으면 보낼 수 있도록 먼저 시각을 맞춥니다.
    _syncRemaining();
    if (!state.canResend || _isResending) return false;
    _isResending = true;
    final SentVerificationCode sentCode;
    try {
      sentCode = await ref
          .read(authRepositoryProvider)
          .sendVerificationCode(phoneNumber, purpose: target.purpose);
    } catch (error, stackTrace) {
      debugPrint('인증번호를 다시 보내지 못했습니다: $error\n$stackTrace');
      if (ref.mounted) {
        state = state.copyWith(failure: () => AuthFailure.unknown);
      }
      return false;
    } finally {
      _isResending = false;
    }
    if (!ref.mounted) return true;
    state = _start(sentCode);
    return true;
  }

  /// 입력한 인증번호를 확인합니다. 맞으면 인증 증명 값을, 아니면 null을 돌려줍니다.
  ///
  /// 틀리면 [AuthFailure.codeMismatch], 확인하지 못하면 [AuthFailure.unknown]을 남깁니다.
  /// 확인에 성공해도 타이머는 멈추지 않아, 뒤로 돌아오면 실제 남은 시간을 보여 줍니다.
  Future<String?> verify() async {
    // Timer 콜백이 밀렸어도 만료된 인증번호를 보내지 않도록 먼저 시각을 맞춥니다.
    _syncRemaining();
    // 다시 보내는 중이면, 곧 무효가 될 이전 인증번호로 확인하지 않습니다.
    if (!state.canVerify || _isResending) return null;
    state = state.copyWith(isSubmitting: true, failure: () => null);
    String? token;
    AuthFailure? failure;
    try {
      token = await ref
          .read(authRepositoryProvider)
          .verifyCode(
            phoneNumber: phoneNumber,
            code: state.code,
            purpose: target.purpose,
          );
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

  /// [sentCode]의 시간으로 만료·다시 받기 시각을 잡고 1초마다 남은 시간을 맞춥니다.
  ///
  /// 처음 상태를 돌려줍니다. 입력칸은 서버가 알려 준 인증번호로 채우거나 비웁니다.
  /// 주기 Timer는 밀린 콜백을 모두 부르지 않으므로, 콜백 횟수를 세지 않고
  /// 정해 둔 시각과 지금 시각의 차이로 남은 시간을 계산합니다.
  PhoneVerificationState _start(SentVerificationCode sentCode) {
    _timer?.cancel();
    final now = _now();
    _expiresAt = now.add(Duration(seconds: sentCode.expiresIn));
    _resendAvailableAt = now.add(Duration(seconds: sentCode.resendAvailableIn));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _syncRemaining();
      if (state.isExpired && state.resendRemainingSeconds <= 0) timer.cancel();
    });
    return PhoneVerificationState(
      remainingSeconds: max(0, sentCode.expiresIn),
      resendRemainingSeconds: max(0, sentCode.resendAvailableIn),
      code: _codeDigits(sentCode.code ?? ''),
    );
  }

  void _syncRemaining() {
    final remaining = _secondsUntil(_expiresAt);
    final resendRemaining = _secondsUntil(_resendAvailableAt);
    if (remaining != state.remainingSeconds ||
        resendRemaining != state.resendRemainingSeconds) {
      state = state.copyWith(
        remainingSeconds: remaining,
        resendRemainingSeconds: resendRemaining,
      );
    }
  }

  /// [time]까지 남은 시간(초). 1초가 안 남았어도 남았으면 1로 올립니다.
  int _secondsUntil(DateTime time) {
    final left = time.difference(_now());
    return max(0, (left.inMilliseconds / 1000).ceil());
  }

  /// 숫자가 아닌 글자와 인증번호 자릿수를 넘는 자리를 버립니다.
  static String _codeDigits(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length > PhoneVerificationState.codeLength
        ? digits.substring(0, PhoneVerificationState.codeLength)
        : digits;
  }
}
