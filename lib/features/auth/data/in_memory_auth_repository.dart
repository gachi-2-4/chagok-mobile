import 'dart:math';

import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/sent_verification_code.dart';
import 'package:chagok_mobile/features/auth/data/social_login_result.dart';
import 'package:chagok_mobile/features/auth/data/verification_purpose.dart';

/// 백엔드가 정해지기 전까지 화면 흐름을 확인하려고 쓰는 메모리 저장소.
///
/// 앱을 끄면 가입 정보가 사라집니다. 인증번호는 실제로 보내지 않고,
/// 인증번호를 보낸 번호에 숫자 6자리를 넣으면 통과시킵니다.
class InMemoryAuthRepository implements AuthRepository {
  final _passwords = <String, String>{};

  /// 인증번호를 보낸 번호와 목적.
  final _codeSentTo = <(String, VerificationPurpose)>{};

  /// 번호·목적마다 마지막으로 내준, 아직 쓰지 않은 인증 증명 값.
  ///
  /// 가입용 증명으로 비밀번호를 바꾸지 못하게 목적까지 묶어 둡니다.
  final _tokens = <(String, VerificationPurpose), String>{};

  final _random = Random.secure();

  static final _sixDigits = RegExp(r'^\d{6}$');

  @override
  Future<SentVerificationCode> sendVerificationCode(
    String phoneNumber, {
    required VerificationPurpose purpose,
  }) async {
    _codeSentTo.add((phoneNumber, purpose));
    return const SentVerificationCode();
  }

  @override
  Future<String?> verifyCode({
    required String phoneNumber,
    required String code,
    required VerificationPurpose purpose,
  }) async {
    if (!_codeSentTo.contains((phoneNumber, purpose)) ||
        !_sixDigits.hasMatch(code)) {
      return null;
    }
    final token = List.generate(
      4,
      (_) => _random.nextInt(1 << 32).toRadixString(16),
    ).join();
    _tokens[(phoneNumber, purpose)] = token;
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
    const purpose = VerificationPurpose.signUp;
    _checkToken(phoneNumber, purpose, verificationToken);
    if (_passwords.containsKey(phoneNumber)) {
      throw const AuthException(AuthFailure.alreadyRegistered);
    }
    _passwords[phoneNumber] = password;
    _consumeToken(phoneNumber, purpose);
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

  /// 카카오 SDK 없이, 약관 동의와 설문을 마친 기존 사용자로 로그인한 것으로 봅니다.
  @override
  Future<SocialLoginResult?> logInWithKakao({
    required bool keepSignedIn,
  }) async => const SocialLoginResult();

  @override
  Future<void> agreeToTerms({required bool agreedToMarketing}) async {}

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
    required String verificationToken,
  }) async {
    const purpose = VerificationPurpose.passwordReset;
    _checkToken(phoneNumber, purpose, verificationToken);
    if (!_passwords.containsKey(phoneNumber)) {
      throw const AuthException(AuthFailure.notRegistered);
    }
    _passwords[phoneNumber] = newPassword;
    _consumeToken(phoneNumber, purpose);
  }

  /// [token]이 [phoneNumber]·[purpose]로 받은 쓰지 않은 증명이 아니면 던집니다.
  void _checkToken(
    String phoneNumber,
    VerificationPurpose purpose,
    String token,
  ) {
    if (_tokens[(phoneNumber, purpose)] != token) {
      throw const AuthException(AuthFailure.notVerified);
    }
  }

  /// 증명을 한 번 쓰면 버려, 같은 값으로 다시 가입·재설정하지 못하게 합니다.
  void _consumeToken(String phoneNumber, VerificationPurpose purpose) {
    _tokens.remove((phoneNumber, purpose));
    _codeSentTo.remove((phoneNumber, purpose));
  }
}
