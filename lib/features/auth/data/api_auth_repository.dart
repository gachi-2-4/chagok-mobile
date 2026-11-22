import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_exception.dart';
import 'package:chagok_mobile/core/network/auth_tokens.dart';
import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/verification_purpose.dart';

/// 차곡 API 서버의 AUTH API로 계정 요청을 처리하는 [AuthRepository].
///
/// 가입·로그인에 성공하면 받은 토큰을 [TokenStorage]에 저장합니다.
/// 서버 에러는 [AuthFailure]로 바꿔 [AuthException]으로 던집니다. 이유를 알 수 없는
/// 에러는 [AuthFailure.unknown]입니다.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({required this._client, required this._tokenStorage});

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  @override
  Future<void> sendVerificationCode(
    String phoneNumber, {
    required VerificationPurpose purpose,
  }) {
    // 비밀번호 재설정 코드는 계정이 있는지 알려 주지 않는 별도 API로 보냅니다.
    final path = switch (purpose) {
      VerificationPurpose.signUp => '/auth/phone/verifications',
      VerificationPurpose.passwordReset => '/auth/password/reset-requests',
    };
    return _guard(
      () => _client.post(
        path,
        body: {'phoneNumber': phoneNumber},
        isAuthenticated: false,
      ),
    );
  }

  @override
  Future<String?> verifyCode({
    required String phoneNumber,
    required String code,
    required VerificationPurpose purpose,
  }) async {
    try {
      final json = await _client.post(
        '/auth/phone/verifications/confirm',
        body: {
          'phoneNumber': phoneNumber,
          'code': code,
          'purpose': _purposeCode(purpose),
        },
        isAuthenticated: false,
      );
      return json.string('verificationToken');
    } on ApiException catch (error) {
      if (error.code == 'INVALID_CODE') return null;
      throw AuthException(_failureOf(error));
    }
  }

  @override
  Future<void> signUp({
    required String phoneNumber,
    required String name,
    required String birthDate,
    required String password,
    required bool agreedToMarketing,
    required String verificationToken,
  }) {
    return _guard(() async {
      final json = await _client.post(
        '/auth/signup',
        body: {
          'phoneNumber': phoneNumber,
          'name': name,
          'birthDate': birthDate,
          'password': password,
          'verificationToken': verificationToken,
          'consents': {
            // 가입 화면(A03)은 필수 약관에 모두 동의해야 이 요청을 보냅니다.
            'termsOfService': true,
            'privacyPolicy': true,
            // 보호자 동의·국외 이전은 A03 디자인에 아직 없어 false로 기록합니다.
            'guardianConsent': false,
            'overseasTransfer': false,
            'marketing': agreedToMarketing,
          },
        },
        isAuthenticated: false,
      );
      await _tokenStorage.save(AuthTokens.fromJson(json));
    });
  }

  @override
  Future<void> logIn({
    required String phoneNumber,
    required String password,
    required bool keepSignedIn,
  }) {
    return _guard(() async {
      final json = await _client.post(
        '/auth/login',
        body: {
          'phoneNumber': phoneNumber,
          'password': password,
          'autoLogin': keepSignedIn,
        },
        isAuthenticated: false,
      );
      // "자동 로그인"을 끄면 앱을 껐다 켰을 때 다시 로그인하도록 기기에 남기지 않습니다.
      await _tokenStorage.save(
        AuthTokens.fromJson(json),
        remember: keepSignedIn,
      );
    });
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
    required String verificationToken,
  }) {
    return _guard(
      () => _client.post(
        '/auth/password/resets',
        body: {
          'phoneNumber': phoneNumber,
          'verificationToken': verificationToken,
          'newPassword': newPassword,
        },
        isAuthenticated: false,
      ),
    );
  }

  /// [request]가 서버 에러로 실패하면 [AuthException]으로 바꿔 던집니다.
  Future<void> _guard(Future<void> Function() request) async {
    try {
      await request();
    } on ApiException catch (error) {
      throw AuthException(_failureOf(error));
    }
  }

  String _purposeCode(VerificationPurpose purpose) => switch (purpose) {
    VerificationPurpose.signUp => 'SIGNUP',
    VerificationPurpose.passwordReset => 'PASSWORD_RESET',
  };

  AuthFailure _failureOf(ApiException error) => switch (error.code) {
    'PHONE_ALREADY_EXISTS' => AuthFailure.alreadyRegistered,
    'INVALID_CREDENTIALS' => AuthFailure.wrongCredentials,
    'INVALID_CODE' => AuthFailure.codeMismatch,
    'INVALID_VERIFICATION_TOKEN' ||
    'CODE_EXPIRED' ||
    'VERIFICATION_NOT_FOUND' ||
    'TOO_MANY_ATTEMPTS' => AuthFailure.notVerified,
    'INVALID_INPUT' => AuthFailure.invalidInput,
    _ => AuthFailure.unknown,
  };
}
