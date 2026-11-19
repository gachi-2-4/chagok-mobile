import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/in_memory_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryAuthRepository repository;

  setUp(() => repository = InMemoryAuthRepository());

  Future<void> signUp({String password = 'chagok12!'}) {
    return repository.signUp(
      phoneNumber: '01011111111',
      name: '김차곡',
      birthDate: '19950321',
      password: password,
      agreedToMarketing: false,
    );
  }

  group('InMemoryAuthRepository', () {
    test('숫자 6자리 인증번호를 넣으면 통과시킨다', () async {
      final isVerified = await repository.verifyCode(
        phoneNumber: '01011111111',
        code: '123456',
      );

      expect(isVerified, isTrue);
    });

    test('6자리가 아닌 인증번호를 넣으면 통과시키지 않는다', () async {
      final isVerified = await repository.verifyCode(
        phoneNumber: '01011111111',
        code: '1234',
      );

      expect(isVerified, isFalse);
    });

    test('가입한 비밀번호로 로그인하면 통과한다', () async {
      await signUp();

      await expectLater(
        repository.logIn(
          phoneNumber: '01011111111',
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
          phoneNumber: '01011111111',
          password: 'wrong',
          keepSignedIn: true,
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('같은 전화번호로 다시 가입하면 AuthException을 던진다', () async {
      await signUp();

      await expectLater(signUp(), throwsA(isA<AuthException>()));
    });

    test('비밀번호를 재설정하면 새 비밀번호로 로그인할 수 있다', () async {
      await signUp();

      await repository.resetPassword(
        phoneNumber: '01011111111',
        newPassword: 'newpass1!',
      );

      await expectLater(
        repository.logIn(
          phoneNumber: '01011111111',
          password: 'newpass1!',
          keepSignedIn: true,
        ),
        completes,
      );
    });

    test('가입하지 않은 번호의 비밀번호를 재설정하면 AuthException을 던진다', () async {
      await expectLater(
        repository.resetPassword(
          phoneNumber: '01099999999',
          newPassword: 'newpass1!',
        ),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
