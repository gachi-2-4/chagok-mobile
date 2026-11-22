import 'package:chagok_mobile/features/auth/data/social_login_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SocialLoginResult.fromJson', () {
    test('서버 응답을 읽으면 약관·설문·빠진 값을 담는다', () {
      final result = SocialLoginResult.fromJson({
        'userId': 1025,
        'isNewUser': true,
        'consentRequired': true,
        'guardianConsentRequired': true,
        'missingFields': ['birthDate', 'phoneNumber'],
        'onboardingCompleted': false,
      });

      expect(
        result,
        const SocialLoginResult(
          isNewUser: true,
          isConsentRequired: true,
          isGuardianConsentRequired: true,
          missingFields: {'birthDate', 'phoneNumber'},
          isOnboardingCompleted: false,
        ),
      );
    });

    test('값이 없으면 기존 사용자로 보고 설문을 마치지 않은 것으로 읽는다', () {
      final result = SocialLoginResult.fromJson({'userId': 1025});

      expect(result.isConsentRequired, isFalse);
      expect(result.missingFields, isEmpty);
      expect(result.isOnboardingCompleted, isFalse);
    });
  });
}
