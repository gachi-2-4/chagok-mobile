import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/core/network/token_storage.dart';
import 'package:chagok_mobile/features/auth/data/api_auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/auth_exception.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/in_memory_auth_repository.dart';
import 'package:chagok_mobile/features/auth/data/kakao_login_client.dart';
import 'package:chagok_mobile/features/auth/data/sent_verification_code.dart';
import 'package:chagok_mobile/features/auth/data/social_login_result.dart';
import 'package:chagok_mobile/features/auth/data/verification_purpose.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 계정 관련 요청(인증번호, 가입, 로그인, 간편 로그인, 비밀번호 재설정)을 처리하는 창구.
///
/// 백엔드가 정해지면 이 인터페이스의 구현만 바꿉니다.
abstract interface class AuthRepository {
  /// [phoneNumber]로 6자리 인증번호를 보내고, 유효 시간과 다시 받기 대기 시간을 돌려줍니다.
  ///
  /// 회원가입과 비밀번호 재설정은 서버에서 보내는 곳이 달라 [purpose]로 고릅니다.
  /// 회원가입인데 이미 가입한 번호면 [AuthFailure.alreadyRegistered]로
  /// [AuthException]을 던집니다.
  Future<SentVerificationCode> sendVerificationCode(
    String phoneNumber, {
    required VerificationPurpose purpose,
  });

  /// [phoneNumber]로 보낸 인증번호가 [code]와 같으면 인증 증명 값을 돌려줍니다.
  ///
  /// 증명 값은 [phoneNumber]·[purpose]에 묶인 일회용 값이고, [signUp]·[resetPassword]에
  /// 넘겨 인증을 마쳤음을 보입니다. 인증번호가 틀리면 null입니다.
  Future<String?> verifyCode({
    required String phoneNumber,
    required String code,
    required VerificationPurpose purpose,
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

  /// 카카오로 로그인합니다. 처음이면 서버가 카카오 정보로 계정을 만듭니다.
  ///
  /// 사용자가 카카오 로그인을 취소하면 null입니다. 카카오 토큰이 맞지 않으면
  /// [AuthFailure.socialTokenInvalid], 같은 전화번호의 전화번호 계정이 있으면
  /// [AuthFailure.phoneAccountExists]로 [AuthException]을 던집니다.
  Future<SocialLoginResult?> logInWithKakao({required bool keepSignedIn});

  /// 간편 로그인으로 만든 계정의 약관 동의를 기록합니다.
  ///
  /// 필수 약관(이용약관·개인정보)은 동의한 것으로 보냅니다. 동의하기 전에는 서버가
  /// AUTH·USER 외 API를 막습니다.
  Future<void> agreeToTerms({required bool agreedToMarketing});

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
///
/// API 서버 주소가 있으면 서버에, 없으면 메모리에 계정을 둡니다.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (!ref.watch(isApiEnabledProvider)) return InMemoryAuthRepository();
  return ApiAuthRepository(
    client: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    kakaoLoginClient: ref.watch(kakaoLoginClientProvider),
  );
});
