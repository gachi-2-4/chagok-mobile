import 'dart:async';

import 'package:chagok_mobile/features/auth/application/auth_clock.dart';
import 'package:chagok_mobile/features/auth/application/phone_verification_notifier.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/sent_verification_code.dart';
import 'package:chagok_mobile/features/auth/data/verification_purpose.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  const phoneNumber = '01066453576';
  final provider = phoneVerificationProvider((
    phoneNumber: phoneNumber,
    purpose: VerificationPurpose.signUp,
    sentCode: const SentVerificationCode(),
  ));

  late FakeAuthRepository repository;
  late ProviderContainer container;
  late DateTime now;

  setUp(() {
    now = DateTime(2026, 11, 20, 9);
    repository = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        authClockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);
  });

  /// autoDispose Provider가 테스트 도중 사라지지 않도록 구독해 둡니다.
  void keepAlive() => container.listen(provider, (_, _) {});

  /// 시계와 가짜 Timer를 함께 [duration]만큼 보냅니다.
  Future<void> elapse(WidgetTester tester, Duration duration) async {
    now = now.add(duration);
    await tester.pump(duration);
  }

  /// testWidgets의 남은 Timer 검사 전에 정리해 타이머를 멈춥니다.
  void disposeNow() => container.dispose();

  group('PhoneVerificationNotifier', () {
    test('처음 읽으면 3분이 남아 있다', () {
      keepAlive();

      expect(
        container.read(provider).remainingSeconds,
        SentVerificationCode.defaultExpiresIn,
      );
    });

    test('보낸 결과에 유효 시간과 다시 받기 대기 시간이 있으면 그 시간으로 시작한다', () {
      const target = (
        phoneNumber: phoneNumber,
        purpose: VerificationPurpose.signUp,
        sentCode: SentVerificationCode(expiresIn: 120, resendAvailableIn: 60),
      );
      container.listen(phoneVerificationProvider(target), (_, _) {});

      final state = container.read(phoneVerificationProvider(target));

      expect(state.remainingSeconds, 120);
      expect(state.resendRemainingSeconds, 60);
      expect(state.canResend, isFalse);
    });

    test('보낸 결과에 인증번호가 있으면 입력칸에 미리 채운다', () {
      const target = (
        phoneNumber: phoneNumber,
        purpose: VerificationPurpose.signUp,
        sentCode: SentVerificationCode(code: '482913'),
      );
      container.listen(phoneVerificationProvider(target), (_, _) {});

      final state = container.read(phoneVerificationProvider(target));

      expect(state.code, '482913');
      expect(state.canVerify, isTrue);
    });

    test('다시 받기 대기 시간이 남았으면 다시 보내지 않고 false를 돌려준다', () async {
      final waitingProvider = phoneVerificationProvider((
        phoneNumber: phoneNumber,
        purpose: VerificationPurpose.signUp,
        sentCode: const SentVerificationCode(resendAvailableIn: 60),
      ));
      container.listen(waitingProvider, (_, _) {});

      final isSent = await container.read(waitingProvider.notifier).resend();

      expect(isSent, isFalse);
      expect(repository.sentCodes, isEmpty);
    });

    test('다시 받기 대기 시간이 지나면 다시 보낸다', () async {
      final waitingProvider = phoneVerificationProvider((
        phoneNumber: phoneNumber,
        purpose: VerificationPurpose.signUp,
        sentCode: const SentVerificationCode(resendAvailableIn: 60),
      ));
      container.listen(waitingProvider, (_, _) {});
      now = now.add(const Duration(seconds: 60));

      final isSent = await container.read(waitingProvider.notifier).resend();

      expect(isSent, isTrue);
      expect(repository.sentCodes, [phoneNumber]);
    });

    testWidgets('시간이 흐르면 다시 받기 대기 시간도 1초마다 줄어든다', (tester) async {
      final waitingProvider = phoneVerificationProvider((
        phoneNumber: phoneNumber,
        purpose: VerificationPurpose.signUp,
        sentCode: const SentVerificationCode(resendAvailableIn: 60),
      ));
      container.listen(waitingProvider, (_, _) {});

      await elapse(tester, const Duration(seconds: 1));
      expect(container.read(waitingProvider).resendRemainingSeconds, 59);

      await elapse(tester, const Duration(seconds: 59));
      expect(container.read(waitingProvider).canResend, isTrue);
      disposeNow();
    });

    // testWidgets 안에서는 Timer가 가짜 시간으로 흐르므로 pump로 시간을 보냅니다.
    testWidgets('시간이 흐르면 1초마다 남은 시간이 줄고 0에서 멈춘다', (tester) async {
      keepAlive();

      await elapse(tester, const Duration(seconds: 1));
      expect(container.read(provider).remainingSeconds, 179);

      await elapse(tester, const Duration(minutes: 5));
      expect(container.read(provider).remainingSeconds, 0);
      expect(container.read(provider).isExpired, isTrue);
      disposeNow();
    });

    testWidgets('Timer 콜백이 밀려 몇 번 빠지면 빠진 만큼이 아니라 실제 흐른 시간만큼 줄인다', (
      tester,
    ) async {
      keepAlive();

      // 앱이 멈춰 있던 사이 4초가 흘렀는데 콜백은 한 번만 온 경우.
      now = now.add(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 1));

      expect(container.read(provider).remainingSeconds, 176);
      disposeNow();
    });

    test('숫자가 아닌 글자나 6자리를 넘는 숫자를 넣으면 버린다', () {
      keepAlive();

      container.read(provider.notifier).updateCode('12a34567');

      expect(container.read(provider).code, '123456');
    });

    test('6자리를 모두 입력하면 확인할 수 있다', () {
      keepAlive();
      final notifier = container.read(provider.notifier);

      notifier.updateCode('12345');
      expect(container.read(provider).canVerify, isFalse);

      notifier.updateCode('123456');
      expect(container.read(provider).canVerify, isTrue);
    });

    testWidgets('만료되면 6자리를 입력해도 확인할 수 없다', (tester) async {
      keepAlive();
      container.read(provider.notifier).updateCode('123456');

      await elapse(tester, const Duration(minutes: 3));

      expect(container.read(provider).canVerify, isFalse);
      disposeNow();
    });

    test('Timer가 오기 전이라도 3분이 지났으면 확인을 보내지 않는다', () async {
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123456');
      now = now.add(const Duration(minutes: 3));

      final token = await notifier.verify();

      expect(token, isNull);
      expect(container.read(provider).isExpired, isTrue);
    });

    test('인증번호가 맞으면 인증 증명 값을 돌려준다', () async {
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123456');

      final token = await notifier.verify();

      expect(token, FakeAuthRepository.tokenFor(phoneNumber));
      expect(container.read(provider).failure, isNull);
    });

    test('인증번호를 다시 보내는 중이면 확인을 보내지 않는다', () async {
      keepAlive();
      repository.sendGate = Completer<void>();
      final notifier = container.read(provider.notifier)..updateCode('123456');

      final resending = notifier.resend();
      final token = await notifier.verify();
      repository.sendGate?.complete();
      await resending;

      expect(token, isNull);
      expect(repository.verifiedPurposes, isEmpty);
    });

    test('인증번호를 다시 보내는 중에 또 다시 보내면 무시하고 false를 돌려준다', () async {
      keepAlive();
      repository.sendGate = Completer<void>();
      final notifier = container.read(provider.notifier);

      final first = notifier.resend();
      final second = await notifier.resend();
      repository.sendGate?.complete();
      await first;

      expect(second, isFalse);
      expect(repository.sentCodes, hasLength(1));
    });

    test('비밀번호 재설정 인증이면 다시 보내기와 확인을 재설정 목적으로 한다', () async {
      final resetProvider = phoneVerificationProvider((
        phoneNumber: phoneNumber,
        purpose: VerificationPurpose.passwordReset,
        sentCode: const SentVerificationCode(),
      ));
      container.listen(resetProvider, (_, _) {});
      final notifier = container.read(resetProvider.notifier);

      await notifier.resend();
      notifier.updateCode('123456');
      await notifier.verify();

      expect(repository.sentPurposes, [VerificationPurpose.passwordReset]);
      expect(repository.verifiedPurposes, [VerificationPurpose.passwordReset]);
    });

    testWidgets('인증에 성공한 뒤 시간이 흐르면 남은 시간이 실제 흐른 만큼 계속 줄어든다', (tester) async {
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123456');
      await notifier.verify();

      await elapse(tester, const Duration(seconds: 10));

      expect(container.read(provider).remainingSeconds, 170);
      disposeNow();
    });

    test('인증번호가 틀리면 codeMismatch를 상태에 담는다', () async {
      repository.isCodeCorrect = false;
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123456');

      final token = await notifier.verify();

      expect(token, isNull);
      expect(container.read(provider).failure, AuthFailure.codeMismatch);
    });

    testWidgets('다시 받으면 인증번호를 보내고 입력과 남은 시간을 처음으로 돌린다', (tester) async {
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123');
      await elapse(tester, const Duration(seconds: 30));

      await notifier.resend();

      final state = container.read(provider);
      expect(repository.sentCodes, [phoneNumber]);
      expect(state.code, isEmpty);
      expect(state.remainingSeconds, SentVerificationCode.defaultExpiresIn);
      disposeNow();
    });

    test('다시 받으면 서버가 준 유효 시간·대기 시간·인증번호로 다시 시작한다', () async {
      keepAlive();
      repository.sentResult = const SentVerificationCode(
        expiresIn: 300,
        resendAvailableIn: 60,
        code: '482913',
      );

      await container.read(provider.notifier).resend();

      final state = container.read(provider);
      expect(state.remainingSeconds, 300);
      expect(state.resendRemainingSeconds, 60);
      expect(state.code, '482913');
    });

    test('인증번호를 확인하는 중이면 다시 받기를 하지 않는다', () async {
      repository.verifyGate = Completer<void>();
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123456');
      final verifying = notifier.verify();

      final isSent = await notifier.resend();
      repository.verifyGate?.complete();
      await verifying;

      expect(isSent, isFalse);
      expect(repository.sentCodes, isEmpty);
    });

    test('인증번호를 확인하지 못하면 unknown을 상태에 담고 확인 중 상태를 푼다', () async {
      repository.error = Exception('network');
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123456');

      final token = await notifier.verify();

      expect(token, isNull);
      expect(container.read(provider).failure, AuthFailure.unknown);
      expect(container.read(provider).isSubmitting, isFalse);
    });

    test('인증번호를 다시 보내지 못하면 false를 돌려주고 unknown을 상태에 담는다', () async {
      repository.sendError = Exception('network');
      keepAlive();

      final isSent = await container.read(provider.notifier).resend();

      expect(isSent, isFalse);
      expect(container.read(provider).failure, AuthFailure.unknown);
    });
  });
}
