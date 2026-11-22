import 'package:chagok_mobile/features/auth/application/social_login_step.dart';
import 'package:chagok_mobile/features/auth/data/social_login_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SocialLoginStep.after', () {
    test('약관 동의가 필요하면 설문보다 약관 동의를 먼저 한다', () {
      const result = SocialLoginResult(
        isConsentRequired: true,
        isOnboardingCompleted: false,
      );

      expect(SocialLoginStep.after(result), SocialLoginStep.terms);
    });

    test('약관 동의를 마쳤고 설문을 마치지 않았으면 설문으로 간다', () {
      const result = SocialLoginResult(isOnboardingCompleted: false);

      expect(SocialLoginStep.after(result), SocialLoginStep.onboarding);
    });

    test('약관 동의와 설문을 모두 마쳤으면 홈으로 간다', () {
      const result = SocialLoginResult();

      expect(SocialLoginStep.after(result), SocialLoginStep.home);
    });
  });
}
