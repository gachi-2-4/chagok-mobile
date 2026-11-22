import 'dart:async';

import 'package:chagok_mobile/features/auth/data/auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/sent_verification_code.dart';
import 'package:chagok_mobile/features/auth/data/social_login_result.dart';
import 'package:chagok_mobile/features/auth/data/verification_purpose.dart';

/// 호출 내용을 기록하고, 정해 둔 결과를 돌려주는 가짜 [AuthRepository].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.error, this.isCodeCorrect = true});

  /// 값이 있으면 가입·로그인·간편 로그인·약관 동의·재설정·인증번호 확인 요청에서
  /// 이 예외를 던집니다.
  Exception? error;

  /// 값이 있으면 인증번호를 보낼 때 이 예외를 던집니다.
  Exception? sendError;

  /// 값을 넣으면 [sendVerificationCode]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? sendGate;

  /// 값을 넣으면 [verifyCode]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? verifyGate;

  /// [sendVerificationCode]가 돌려줄 결과.
  SentVerificationCode sentResult = const SentVerificationCode();

  /// [verifyCode]가 성공할지 여부.
  bool isCodeCorrect;

  final sentCodes = <String>[];

  /// [sentCodes]와 같은 순서로, 인증번호를 보낸 목적.
  final sentPurposes = <VerificationPurpose>[];

  /// [verifyCode]에 넘어온 목적.
  final verifiedPurposes = <VerificationPurpose>[];
  final signUps = <Map<String, Object>>[];
  final logIns = <Map<String, Object>>[];
  final resets = <Map<String, Object>>[];

  /// [logInWithKakao]가 돌려줄 결과. null이면 사용자가 취소한 것으로 봅니다.
  SocialLoginResult? kakaoResult = const SocialLoginResult();

  /// [logInWithKakao]에 넘어온 자동 로그인 여부.
  final kakaoLogIns = <bool>[];

  /// [agreeToTerms]에 넘어온 마케팅 동의 여부.
  final termsAgreements = <bool>[];

  /// [verifyCode]가 [phoneNumber]에 돌려주는 인증 증명 값.
  static String tokenFor(String phoneNumber) => 'token-$phoneNumber';

  @override
  Future<SentVerificationCode> sendVerificationCode(
    String phoneNumber, {
    required VerificationPurpose purpose,
  }) async {
    await sendGate?.future;
    if (sendError case final error?) throw error;
    sentCodes.add(phoneNumber);
    sentPurposes.add(purpose);
    return sentResult;
  }

  @override
  Future<String?> verifyCode({
    required String phoneNumber,
    required String code,
    required VerificationPurpose purpose,
  }) async {
    verifiedPurposes.add(purpose);
    await verifyGate?.future;
    _throwIfNeeded();
    return isCodeCorrect ? tokenFor(phoneNumber) : null;
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
    _throwIfNeeded();
    signUps.add({
      'phoneNumber': phoneNumber,
      'name': name,
      'birthDate': birthDate,
      'password': password,
      'agreedToMarketing': agreedToMarketing,
      'verificationToken': verificationToken,
    });
  }

  @override
  Future<void> logIn({
    required String phoneNumber,
    required String password,
    required bool keepSignedIn,
  }) async {
    _throwIfNeeded();
    logIns.add({
      'phoneNumber': phoneNumber,
      'password': password,
      'keepSignedIn': keepSignedIn,
    });
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
    required String verificationToken,
  }) async {
    _throwIfNeeded();
    resets.add({
      'phoneNumber': phoneNumber,
      'newPassword': newPassword,
      'verificationToken': verificationToken,
    });
  }

  @override
  Future<SocialLoginResult?> logInWithKakao({
    required bool keepSignedIn,
  }) async {
    _throwIfNeeded();
    kakaoLogIns.add(keepSignedIn);
    return kakaoResult;
  }

  @override
  Future<void> agreeToTerms({required bool agreedToMarketing}) async {
    _throwIfNeeded();
    termsAgreements.add(agreedToMarketing);
  }

  void _throwIfNeeded() {
    final error = this.error;
    if (error != null) throw error;
  }
}
