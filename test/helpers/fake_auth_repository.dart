import 'dart:async';

import 'package:chagok_mobile/features/auth/data/auth_repository.dart';

/// 호출 내용을 기록하고, 정해 둔 결과를 돌려주는 가짜 [AuthRepository].
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.error, this.isCodeCorrect = true});

  /// 값이 있으면 가입·로그인·재설정·인증번호 확인 요청에서 이 예외를 던집니다.
  Exception? error;

  /// 값이 있으면 인증번호를 보낼 때 이 예외를 던집니다.
  Exception? sendError;

  /// 값을 넣으면 [sendVerificationCode]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? sendGate;

  /// 값을 넣으면 [verifyCode]가 이것이 끝날 때까지 기다립니다.
  Completer<void>? verifyGate;

  /// [verifyCode]가 성공할지 여부.
  bool isCodeCorrect;

  final sentCodes = <String>[];
  final signUps = <Map<String, Object>>[];
  final logIns = <Map<String, Object>>[];
  final resets = <Map<String, Object>>[];

  /// [verifyCode]가 [phoneNumber]에 돌려주는 인증 증명 값.
  static String tokenFor(String phoneNumber) => 'token-$phoneNumber';

  @override
  Future<void> sendVerificationCode(String phoneNumber) async {
    await sendGate?.future;
    if (sendError case final error?) throw error;
    sentCodes.add(phoneNumber);
  }

  @override
  Future<String?> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
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

  void _throwIfNeeded() {
    final error = this.error;
    if (error != null) throw error;
  }
}
