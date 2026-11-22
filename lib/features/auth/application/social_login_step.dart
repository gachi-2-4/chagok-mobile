import 'package:chagok_mobile/features/auth/data/social_login_result.dart';

/// 간편 로그인을 마친 뒤 이어 갈 단계.
enum SocialLoginStep {
  /// 필수 약관에 아직 동의하지 않아 약관 동의(A03)부터 합니다.
  terms,

  /// 첫 설문(온보딩)을 아직 마치지 않았습니다.
  onboarding,

  /// 모두 마쳐 홈으로 갑니다.
  home;

  /// [result]를 보고 다음 단계를 고릅니다. 약관 동의가 설문보다 먼저입니다.
  static SocialLoginStep after(SocialLoginResult result) => switch (result) {
    SocialLoginResult(isConsentRequired: true) => terms,
    SocialLoginResult(isOnboardingCompleted: false) => onboarding,
    _ => home,
  };
}
