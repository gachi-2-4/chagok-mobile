import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/in_memory_auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 계정 관련 요청(인증번호, 가입, 로그인, 비밀번호 재설정)을 처리하는 창구.
///
/// 백엔드가 정해지면 이 인터페이스의 구현만 바꿉니다.
abstract interface class AuthRepository {
  /// [phoneNumber]로 6자리 인증번호를 보냅니다.
  Future<void> sendVerificationCode(String phoneNumber);

  /// [phoneNumber]로 보낸 인증번호가 [code]와 같으면 인증 증명 값을 돌려줍니다.
  ///
  /// 증명 값은 [phoneNumber]에 묶인 일회용 값이고, [signUp]·[resetPassword]에
  /// 넘겨 인증을 마쳤음을 보입니다. 인증번호가 틀리면 null입니다.
  Future<String?> verifyCode({
    required String phoneNumber,
    required String code,
  });

  /// 새 계정을 만듭니다.
  ///
  /// [verificationToken]이 [phoneNumber]로 받은 유효한 증명이 아니면
  /// [AuthFailure.notVerified], 이미 가입한 전화번호면
  /// [AuthFailure.alreadyRegistered]로 [AuthException]을 던집니다.
  /// 가입하면 증명 값은 다시 쓸 수 없습니다.
  Future<void> signUp({
    required String phoneNumber,
    required String name,
    required String birthDate,
    required String password,
    required bool agreedToMarketing,
    required String verificationToken,
  });

  /// 로그인합니다. 정보가 맞지 않으면 [AuthException]을 던집니다.
  Future<void> logIn({
    required String phoneNumber,
    required String password,
    required bool keepSignedIn,
  });

  /// 비밀번호를 [newPassword]로 바꿉니다.
  ///
  /// 전화번호만으로 남의 비밀번호를 바꾸지 못하도록, [verificationToken]이
  /// [phoneNumber]로 받은 유효한 증명이 아니면 [AuthFailure.notVerified]로
  /// [AuthException]을 던집니다. 바꾸면 증명 값은 다시 쓸 수 없습니다.
  /// 실제 백엔드에서도 서버가 같은 검사를 해야 합니다.
  Future<void> resetPassword({
    required String phoneNumber,
    required String newPassword,
    required String verificationToken,
  });
}

/// 앱 전역 [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // TODO: 백엔드가 정해지면 실제 구현으로 바꿉니다.
  return InMemoryAuthRepository();
});
