import 'package:chagok_mobile/features/auth/application/phone_verification_notifier.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  const phoneNumber = '01066453576';
  final provider = phoneVerificationProvider(phoneNumber);

  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  /// autoDispose Provider가 테스트 도중 사라지지 않도록 구독해 둡니다.
  void keepAlive() => container.listen(provider, (_, _) {});

  group('PhoneVerificationNotifier', () {
    test('처음에는 3분이 남아 있다', () {
      keepAlive();

      expect(
        container.read(provider).remainingSeconds,
        PhoneVerificationNotifier.codeLifetimeSeconds,
      );
    });

    // testWidgets 안에서는 Timer가 가짜 시간으로 흐르므로 pump로 시간을 보냅니다.
    testWidgets('1초마다 남은 시간이 줄고 0에서 멈춘다', (tester) async {
      keepAlive();

      await tester.pump(const Duration(seconds: 1));
      expect(container.read(provider).remainingSeconds, 179);

      await tester.pump(const Duration(minutes: 5));
      expect(container.read(provider).remainingSeconds, 0);
      expect(container.read(provider).isExpired, isTrue);
    });

    test('숫자가 아닌 글자와 6자리를 넘는 숫자는 버린다', () {
      keepAlive();

      container.read(provider.notifier).updateCode('12a34567');

      expect(container.read(provider).code, '123456');
    });

    test('6자리를 모두 입력해야 확인할 수 있다', () {
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

      await tester.pump(const Duration(minutes: 3));

      expect(container.read(provider).canVerify, isFalse);
    });

    test('인증번호가 맞으면 true를 돌려준다', () async {
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123456');

      final isVerified = await notifier.verify();

      expect(isVerified, isTrue);
      expect(container.read(provider).errorMessage, isNull);
    });

    test('인증번호가 틀리면 오류 문구를 상태에 담는다', () async {
      repository.isCodeCorrect = false;
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123456');

      final isVerified = await notifier.verify();

      expect(isVerified, isFalse);
      expect(container.read(provider).errorMessage, isNotNull);
    });

    testWidgets('다시 받으면 인증번호를 보내고 입력과 남은 시간을 처음으로 돌린다', (tester) async {
      keepAlive();
      final notifier = container.read(provider.notifier)..updateCode('123');
      await tester.pump(const Duration(seconds: 30));

      await notifier.resend();

      final state = container.read(provider);
      expect(repository.sentCodes, [phoneNumber]);
      expect(state.code, isEmpty);
      expect(
        state.remainingSeconds,
        PhoneVerificationNotifier.codeLifetimeSeconds,
      );
      // 테스트가 끝나기 전에 타이머가 멈추도록 만료될 때까지 시간을 보냅니다.
      await tester.pump(const Duration(minutes: 3));
    });
  });
}
