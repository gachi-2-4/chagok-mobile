import 'package:chagok_mobile/core/network/secure_token_storage.dart';
import 'package:chagok_mobile/features/auth/data/api_auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/verification_purpose.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_api_server.dart';

void main() {
  const phoneNumber = '01012345678';
  const tokens = {
    'userId': 1024,
    'accessToken': 'access-new',
    'refreshToken': 'refresh-new',
    'onboardingCompleted': false,
  };

  late FakeApiServer server;
  late ApiAuthRepository repository;

  setUp(() {
    server = FakeApiServer();
    repository = ApiAuthRepository(
      client: server.client,
      tokenStorage: server.tokenStorage,
    );
  });

  Matcher throwsFailure(AuthFailure failure) => throwsA(
    isA<AuthException>().having((error) => error.failure, 'failure', failure),
  );

  group('ApiAuthRepository.sendVerificationCode', () {
    test('회원가입 목적이면 인증번호 발송 API로 보낸다', () async {
      server.onJson('POST', '/auth/phone/verifications', {'expiresIn': 180});

      await repository.sendVerificationCode(
        phoneNumber,
        purpose: VerificationPurpose.signUp,
      );

      expect(server.lastBody('POST', '/auth/phone/verifications'), {
        'phoneNumber': phoneNumber,
      });
    });

    test('비밀번호 재설정 목적이면 재설정 요청 API로 보낸다', () async {
      server.onJson('POST', '/auth/password/reset-requests', {
        'expiresIn': 180,
      });

      await repository.sendVerificationCode(
        phoneNumber,
        purpose: VerificationPurpose.passwordReset,
      );

      expect(server.requestsTo('POST', '/auth/password/reset-requests'), [
        isNotNull,
      ]);
    });

    test('이미 가입한 번호면 alreadyRegistered로 던진다', () async {
      server.on(
        'POST',
        '/auth/phone/verifications',
        (_) => errorResponse(409, 'PHONE_ALREADY_EXISTS'),
      );

      final request = repository.sendVerificationCode(
        phoneNumber,
        purpose: VerificationPurpose.signUp,
      );

      await expectLater(request, throwsFailure(AuthFailure.alreadyRegistered));
    });

    test('보낸 값이 입력 규칙에 맞지 않으면 invalidInput으로 던진다', () async {
      server.on(
        'POST',
        '/auth/phone/verifications',
        (_) => errorResponse(400, 'INVALID_INPUT', '잘못된 요청입니다.'),
      );

      final request = repository.sendVerificationCode(
        phoneNumber,
        purpose: VerificationPurpose.signUp,
      );

      await expectLater(request, throwsFailure(AuthFailure.invalidInput));
    });
  });

  group('ApiAuthRepository.verifyCode', () {
    test('인증번호가 맞으면 받은 인증 토큰을 돌려준다', () async {
      server.onJson('POST', '/auth/phone/verifications/confirm', {
        'verificationToken': 'vt_1',
        'expiresIn': 600,
      });

      final token = await repository.verifyCode(
        phoneNumber: phoneNumber,
        code: '246813',
        purpose: VerificationPurpose.passwordReset,
      );

      expect(token, 'vt_1');
      expect(
        server.lastBody('POST', '/auth/phone/verifications/confirm'),
        containsPair('purpose', 'PASSWORD_RESET'),
      );
    });

    test('인증번호가 틀리면 null을 돌려준다', () async {
      server.on(
        'POST',
        '/auth/phone/verifications/confirm',
        (_) => errorResponse(400, 'INVALID_CODE'),
      );

      final token = await repository.verifyCode(
        phoneNumber: phoneNumber,
        code: '000000',
        purpose: VerificationPurpose.signUp,
      );

      expect(token, isNull);
    });

    test('인증번호가 만료됐으면 notVerified로 던진다', () async {
      server.on(
        'POST',
        '/auth/phone/verifications/confirm',
        (_) => errorResponse(400, 'CODE_EXPIRED'),
      );

      final request = repository.verifyCode(
        phoneNumber: phoneNumber,
        code: '246813',
        purpose: VerificationPurpose.signUp,
      );

      await expectLater(request, throwsFailure(AuthFailure.notVerified));
    });
  });

  group('ApiAuthRepository.signUp', () {
    test('가입하면 약관 동의를 함께 보내고 받은 토큰을 저장한다', () async {
      server.onJson('POST', '/auth/signup', tokens, status: 201);

      await repository.signUp(
        phoneNumber: phoneNumber,
        name: '이차곡',
        birthDate: '2001-03-14',
        password: 'chagok1234!',
        agreedToMarketing: true,
        verificationToken: 'vt_1',
      );

      expect(
        server.lastBody('POST', '/auth/signup')['consents'],
        containsPair('marketing', true),
      );
      expect((await server.tokenStorage.read())?.accessToken, 'access-new');
    });

    test('인증 토큰이 만료됐으면 notVerified로 던진다', () async {
      server.on(
        'POST',
        '/auth/signup',
        (_) => errorResponse(401, 'INVALID_VERIFICATION_TOKEN'),
      );

      final request = repository.signUp(
        phoneNumber: phoneNumber,
        name: '이차곡',
        birthDate: '2001-03-14',
        password: 'chagok1234!',
        agreedToMarketing: false,
        verificationToken: 'vt_old',
      );

      await expectLater(request, throwsFailure(AuthFailure.notVerified));
    });
  });

  group('ApiAuthRepository.logIn', () {
    for (final (keepSignedIn, isKeptOnDevice) in [
      (true, true),
      (false, false),
    ]) {
      test(
        '자동 로그인이 $keepSignedIn이면 앱을 다시 열 때 토큰이 ${isKeptOnDevice ? '남아 있다' : '없다'}',
        () async {
          FlutterSecureStorage.setMockInitialValues({});
          server.onJson('POST', '/auth/login', tokens);
          final deviceRepository = ApiAuthRepository(
            client: server.client,
            tokenStorage: SecureTokenStorage(),
          );

          await deviceRepository.logIn(
            phoneNumber: phoneNumber,
            password: 'chagok1234!',
            keepSignedIn: keepSignedIn,
          );

          final reopened = await SecureTokenStorage().read();
          expect(reopened != null, isKeptOnDevice);
        },
      );
    }

    test('로그인하면 자동 로그인 여부를 보내고 받은 토큰을 저장한다', () async {
      server.onJson('POST', '/auth/login', tokens);

      await repository.logIn(
        phoneNumber: phoneNumber,
        password: 'chagok1234!',
        keepSignedIn: false,
      );

      expect(
        server.lastBody('POST', '/auth/login'),
        containsPair('autoLogin', false),
      );
      expect((await server.tokenStorage.read())?.refreshToken, 'refresh-new');
    });

    test('정보가 맞지 않으면 wrongCredentials로 던진다', () async {
      server.on(
        'POST',
        '/auth/login',
        (_) => errorResponse(401, 'INVALID_CREDENTIALS'),
      );

      final request = repository.logIn(
        phoneNumber: phoneNumber,
        password: 'wrong',
        keepSignedIn: true,
      );

      await expectLater(request, throwsFailure(AuthFailure.wrongCredentials));
    });

    test('로그인이 잠겼으면 unknown으로 던진다', () async {
      server.on(
        'POST',
        '/auth/login',
        (_) => errorResponse(429, 'LOGIN_LOCKED'),
      );

      final request = repository.logIn(
        phoneNumber: phoneNumber,
        password: 'wrong',
        keepSignedIn: true,
      );

      await expectLater(request, throwsFailure(AuthFailure.unknown));
    });
  });

  group('ApiAuthRepository.resetPassword', () {
    test('비밀번호를 바꾸면 인증 토큰과 새 비밀번호를 보낸다', () async {
      server.on('POST', '/auth/password/resets', (_) => emptyResponse());

      await repository.resetPassword(
        phoneNumber: phoneNumber,
        newPassword: 'chagok5678!',
        verificationToken: 'vt_2',
      );

      expect(server.lastBody('POST', '/auth/password/resets'), {
        'phoneNumber': phoneNumber,
        'verificationToken': 'vt_2',
        'newPassword': 'chagok5678!',
      });
    });
  });
}
