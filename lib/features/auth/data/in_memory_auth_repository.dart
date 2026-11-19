import 'package:chagok_mobile/features/auth/data/auth_repository.dart';

/// 백엔드가 정해지기 전까지 화면 흐름을 확인하려고 쓰는 메모리 저장소.
///
/// 앱을 끄면 가입 정보가 사라집니다. 인증번호는 실제로 보내지 않고
/// 숫자 6자리면 통과시킵니다.
class InMemoryAuthRepository implements AuthRepository {
  final _passwords = <String, String>{};

  @override
  Future<void> sendVerificationCode(String phoneNumber) async {}

  @override
  Future<bool> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  @override
  Future<void> signUp({
    required String phoneNumber,
    required String name,
    required String birthDate,
    required String password,
    required bool agreedToMarketing,
  }) async {
    if (_passwords.containsKey(phoneNumber)) {
      throw const AuthException('이미 가입한 전화번호예요.');
    }
    _passwords[phoneNumber] = password;
  }

  @override
  Future<void> logIn({
    required String phoneNumber,
    required String password,
    required bool keepSignedIn,
  }) async {
    if (_passwords[phoneNumber] != password) {
      throw const AuthException('전화번호 또는 비밀번호가 맞지 않아요.');
    }
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    if (!_passwords.containsKey(phoneNumber)) {
      throw const AuthException('가입하지 않은 전화번호예요.');
    }
    _passwords[phoneNumber] = newPassword;
  }
}
