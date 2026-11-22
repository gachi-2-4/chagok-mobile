import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';

/// 회원가입·로그인 화면에 보이는 문구.
///
/// 다국어를 도입할 때 옮기기 쉽도록 한곳에 모읍니다.
abstract final class AuthStrings {
  // 공통
  static const phoneLabel = '전화번호';
  static const phoneHint = '010-0000-0000';
  static const passwordLabel = '비밀번호';
  static const passwordHint = '비밀번호 입력';
  static const passwordRule = '8자 이상, 숫자와 특수문자(!, @, # 등)를 포함해 주세요.';
  static const passwordMismatch = '비밀번호가 다릅니다.';
  static const showPassword = '비밀번호 보기';
  static const hidePassword = '비밀번호 숨기기';
  static const comingSoon = '곧 지원할 예정이에요.';

  /// 계정 요청이 실패한 이유에 맞는 안내.
  static String failure(AuthFailure value) => switch (value) {
    AuthFailure.alreadyRegistered => '이미 가입한 전화번호예요.',
    AuthFailure.wrongCredentials => '전화번호 또는 비밀번호가 맞지 않아요.',
    AuthFailure.notRegistered => '가입하지 않은 전화번호예요.',
    AuthFailure.notVerified => '인증이 끝났거나 만료됐어요. 인증번호를 다시 받아 주세요.',
    AuthFailure.codeMismatch => '인증번호가 맞지 않아요.',
    AuthFailure.invalidInput => '입력한 정보를 다시 확인해 주세요.',
    AuthFailure.unknown => '요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요.',
  };

  // A01 회원가입
  static const signUpBarTitle = '회원가입';
  static const signUpTitle = '처음 만나는 차곡';
  static const signUpDescription = '내 서류를 쉽고 안전하게 정리해요.';
  static const nameLabel = '이름';
  static const nameHint = '이름 입력';
  static const birthDateLabel = '생년월일';
  static const birthDateHint = 'YYYY.MM.DD';
  static const passwordConfirmLabel = '비밀번호 확인';
  static const passwordConfirmHint = '비밀번호 다시 입력';
  static const hasAccount = '이미 계정이 있나요?';
  static const goToLogin = '로그인';
  static const requestCode = '인증번호 받기';

  // A02·L04 전화번호 인증
  static const verificationBarTitle = '전화번호 인증';
  static const verificationTitle = '문자를 확인해 주세요';
  static String verificationDescription(String maskedPhoneNumber) =>
      '$maskedPhoneNumber으로 보낸 인증번호 6자리를 입력해 주세요.';
  static const remainingTime = '남은 시간';
  static const resendCode = '인증번호 다시 받기';
  static const codeResent = '인증번호를 다시 보냈어요.';
  static const codeExpired = '인증번호가 만료됐어요. 다시 받아 주세요.';
  static const noCodeReceived = '문자가 오지 않았나요? 스팸함을 확인하거나 인증번호를 다시 받아 주세요.';
  static const passwordResetCodeSent =
      '입력한 전화번호로 인증번호를 보냈어요. 문자가 오지 않으면 다시 받아 주세요.';
  static const verifyAndContinue = '인증하고 계속하기';
  static const codeFieldLabel = '인증번호 6자리';

  // A03 약관 동의
  static const termsBarTitle = '이용약관';
  static const termsTitle = '시작 전, 확인해 주세요';
  static const termsDescription = '서류를 안전하게 보관하기 위한 약속이에요.';
  static const agreeToAll = '전체 동의';
  static const requiredSuffix = '(필수)';
  static const optionalSuffix = '(선택)';
  static const viewTerm = '보기 ›';

  /// 약관 이름.
  static String term(Term value) => switch (value) {
    Term.service => '서비스 이용약관',
    Term.privacy => '개인정보 수집·이용',
    Term.marketing => '마케팅 수신',
  };

  /// 약관 한 줄의 이름과 필수·선택 표시. 예: "서비스 이용약관 (필수)"
  static String termLabel(Term value) =>
      '${term(value)} ${value.isRequired ? requiredSuffix : optionalSuffix}';
  static const agreeAndComplete = '동의하고 가입 완료';

  // L01 로그인
  static const logoLabel = '차곡';
  static const keepSignedIn = '자동 로그인';
  static const findPassword = '비밀번호 찾기';
  static const noAccount = '아직 계정이 없나요?';
  static const goToSignUp = '회원가입';
  static const logIn = '로그인';
  static const socialLogin = '간편 로그인';
  static const kakaoLogin = 'kakao 로그인';
  static const googleLogin = 'Google 로그인';

  // L02 비밀번호 찾기
  static const forgotPasswordTitle = '비밀번호를 잊으셨나요?';
  static const forgotPasswordDescription =
      '가입할 때 사용한 전화번호를 알려 주세요. 인증 코드를 보내 드려요.';
  static const sendCode = '인증 코드 보내기';

  // L03 새 비밀번호
  static const resetPasswordTitle = '새 비밀번호 만들기';
  static const resetPasswordDescription = '이전과 다른 비밀번호로 내 서류를 안전하게 지켜 주세요';
  static const newPasswordLabel = '새 비밀번호';
  static const newPasswordConfirmLabel = '새 비밀번호 확인';
  static const changePassword = '비밀번호 변경';
  static const passwordChanged = '비밀번호를 바꿨어요. 새 비밀번호로 로그인해 주세요.';
}
