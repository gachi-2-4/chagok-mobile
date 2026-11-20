import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/in_memory_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const phoneNumber = '01011111111';
  late InMemoryAuthRepository repository;

  setUp(() => repository = InMemoryAuthRepository());

  /// [number]로 인증번호를 보내고 확인해 인증 증명 값을 받습니다.
  Future<String> verify([String number = phoneNumber]) async {
    await repository.sendVerificationCode(number);
    final token = await repository.verifyCode(
      phoneNumber: number,
      code: '123456',
    );
    return token ?? fail('인증하지 못했습니다');
  }

  Future<void> signUp({String password = 'chagok12!'}) async {
    return repository.signUp(
      phoneNumber: phoneNumber,
      name: '김차곡',
      birthDate: '19950321',
      password: password,
      agreedToMarketing: false,
      verificationToken: await verify(),
    );
  }

  Matcher throwsFailure(AuthFailure failure) => throwsA(
    isA<AuthException>().having((error) => error.failure, 'failure', failure),
  );

  group('InMemoryAuthRepository', () {
    test('보낸 번호에 숫자 6자리 인증번호를 넣으면 인증 증명 값을 돌려준다', () async {
      await repository.sendVerificationCode(phoneNumber);

      final token = await repository.verifyCode(
        phoneNumber: phoneNumber,
        code: '123456',
      );

      expect(token, isNotNull);
    });

    test('6자리가 아닌 인증번호를 넣으면 통과시키지 않는다', () async {
      await repository.sendVerificationCode(phoneNumber);

      final token = await repository.verifyCode(
        phoneNumber: phoneNumber,
        code: '1234',
      );

      expect(token, isNull);
    });

    test('인증번호를 보내지 않은 번호에 6자리를 넣으면 통과시키지 않는다', () async {
      final token = await repository.verifyCode(
        phoneNumber: phoneNumber,
        code: '123456',
      );

      expect(token, isNull);
    });

    test('가입한 비밀번호로 로그인하면 통과한다', () async {
      await signUp();

      await expectLater(
        repository.logIn(
          phoneNumber: phoneNumber,
          password: 'chagok12!',
          keepSignedIn: true,
        ),
        completes,
      );
    });

    test('비밀번호가 틀리면 로그인에서 AuthException을 던진다', () async {
      await signUp();

      await expectLater(
        repository.logIn(
          phoneNumber: phoneNumber,
          password: 'wrong',
          keepSignedIn: true,
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('같은 전화번호로 다시 가입하면 alreadyRegistered를 던진다', () async {
      await signUp();

      await expectLater(signUp(), throwsFailure(AuthFailure.alreadyRegistered));
    });

    test('인증하지 않은 증명 값으로 가입하면 notVerified를 던진다', () async {
      await expectLater(
        repository.signUp(
          phoneNumber: phoneNumber,
          name: '김차곡',
          birthDate: '19950321',
          password: 'chagok12!',
          agreedToMarketing: false,
          verificationToken: 'forged',
        ),
        throwsFailure(AuthFailure.notVerified),
      );
    });

    test('인증 증명 값으로 비밀번호를 재설정하면 새 비밀번호로 로그인할 수 있다', () async {
      await signUp();

      await repository.resetPassword(
        phoneNumber: phoneNumber,
        newPassword: 'newpass1!',
        verificationToken: await verify(),
      );

      await expectLater(
        repository.logIn(
          phoneNumber: phoneNumber,
          password: 'newpass1!',
          keepSignedIn: true,
        ),
        completes,
      );
    });

    test('인증하지 않고 비밀번호를 재설정하면 notVerified를 던지고 비밀번호를 그대로 둔다', () async {
      await signUp();

      await expectLater(
        repository.resetPassword(
          phoneNumber: phoneNumber,
          newPassword: 'hacked12!',
          verificationToken: 'forged',
        ),
        throwsFailure(AuthFailure.notVerified),
      );
      await expectLater(
        repository.logIn(
          phoneNumber: phoneNumber,
          password: 'chagok12!',
          keepSignedIn: true,
        ),
        completes,
      );
    });

    test('다른 번호로 받은 인증 증명 값으로 재설정하면 notVerified를 던진다', () async {
      await signUp();
      final otherToken = await verify('01022222222');

      await expectLater(
        repository.resetPassword(
          phoneNumber: phoneNumber,
          newPassword: 'hacked12!',
          verificationToken: otherToken,
        ),
        throwsFailure(AuthFailure.notVerified),
      );
    });

    test('한 번 쓴 인증 증명 값으로 다시 재설정하면 notVerified를 던진다', () async {
      await signUp();
      final token = await verify();
      await repository.resetPassword(
        phoneNumber: phoneNumber,
        newPassword: 'newpass1!',
        verificationToken: token,
      );

      await expectLater(
        repository.resetPassword(
          phoneNumber: phoneNumber,
          newPassword: 'again12!',
          verificationToken: token,
        ),
        throwsFailure(AuthFailure.notVerified),
      );
    });

    test('가입하지 않은 번호의 비밀번호를 재설정하면 notRegistered를 던진다', () async {
      const unknown = '01099999999';

      await expectLater(
        repository.resetPassword(
          phoneNumber: unknown,
          newPassword: 'newpass1!',
          verificationToken: await verify(unknown),
        ),
        throwsFailure(AuthFailure.notRegistered),
      );
    });
  });
}
