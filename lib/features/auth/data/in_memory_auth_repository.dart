import 'dart:math';

import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';

/// 백엔드가 정해지기 전까지 화면 흐름을 확인하려고 쓰는 메모리 저장소.
///
/// 앱을 끄면 가입 정보가 사라집니다. 인증번호는 실제로 보내지 않고,
/// 인증번호를 보낸 번호에 숫자 6자리를 넣으면 통과시킵니다.
class InMemoryAuthRepository implements AuthRepository {
  final _passwords = <String, String>{};

  /// 인증번호를 보낸 번호.
  final _codeSentTo = <String>{};

  /// 번호마다 마지막으로 내준, 아직 쓰지 않은 인증 증명 값.
  final _tokens = <String, String>{};

  final _random = Random.secure();

  static final _sixDigits = RegExp(r'^\d{6}$');

  @override
  Future<void> sendVerificationCode(String phoneNumber) async {
    _codeSentTo.add(phoneNumber);
  }

  @override
  Future<String?> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    if (!_codeSentTo.contains(phoneNumber) || !_sixDigits.hasMatch(code)) {
      return null;
    }
    final token = List.generate(
      4,
      (_) => _random.nextInt(1 << 32).toRadixString(16),
    ).join();
    _tokens[phoneNumber] = token;
    return token;
  }

  @override
  Future<void> signUp({
    required String phoneNumber,
    required String name,
    required String birthDate,
    required String password,
    required bool agreedToMarketing,
    required String verificationToken,
  }) async {
    _checkToken(phoneNumber, verificationToken);
    if (_passwords.containsKey(phoneNumber)) {
      throw const AuthException(AuthFailure.alreadyRegistered);
    }
    _passwords[phoneNumber] = password;
    _consumeToken(phoneNumber);
  }

  @override
  Future<void> logIn({
    required String phoneNumber,
    required String password,
    required bool keepSignedIn,
  }) async {
    if (_passwords[phoneNumber] != password) {
      throw const AuthException(AuthFailure.wrongCredentials);
    }
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
    required String verificationToken,
  }) async {
    _checkToken(phoneNumber, verificationToken);
    if (!_passwords.containsKey(phoneNumber)) {
      throw const AuthException(AuthFailure.notRegistered);
    }
    _passwords[phoneNumber] = newPassword;
    _consumeToken(phoneNumber);
  }

  /// [token]이 [phoneNumber]로 받은 쓰지 않은 증명이 아니면 던집니다.
  void _checkToken(String phoneNumber, String token) {
    if (_tokens[phoneNumber] != token) {
      throw const AuthException(AuthFailure.notVerified);
    }
  }

  /// 증명을 한 번 쓰면 버려, 같은 값으로 다시 가입·재설정하지 못하게 합니다.
  void _consumeToken(String phoneNumber) {
    _tokens.remove(phoneNumber);
    _codeSentTo.remove(phoneNumber);
  }
}
