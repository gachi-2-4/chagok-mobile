import 'package:chagok_mobile/core/network/json_map.dart';
import 'package:flutter/foundation.dart';

/// 카카오 등 간편 로그인의 결과. 로그인 뒤 어느 화면으로 갈지 정하는 데 씁니다.
class SocialLoginResult {
  const SocialLoginResult({
    this.isNewUser = false,
    this.isConsentRequired = false,
    this.isGuardianConsentRequired = false,
    this.missingFields = const {},
    this.isOnboardingCompleted = true,
  });

  /// 서버 응답(`POST /auth/kakao`)에서 만듭니다.
  factory SocialLoginResult.fromJson(JsonMap json) => SocialLoginResult(
    isNewUser: json.boolean('isNewUser'),
    isConsentRequired: json.boolean('consentRequired'),
    isGuardianConsentRequired: json.boolean('guardianConsentRequired'),
    missingFields: json.strings('missingFields').toSet(),
    isOnboardingCompleted: json.boolean('onboardingCompleted'),
  );

  /// 이번 로그인으로 계정을 새로 만들었으면 true.
  final bool isNewUser;

  /// 필수 약관에 아직 동의하지 않았으면 true. 약관 동의(A03)부터 합니다.
  final bool isConsentRequired;

  /// 만 14세 미만이라 보호자 동의가 필요하면 true.
  final bool isGuardianConsentRequired;

  /// 카카오에서 받지 못한 값. `name`·`birthDate`·`phoneNumber`. 온보딩에서 받습니다.
  final Set<String> missingFields;

  /// 첫 설문(온보딩)을 마쳤으면 true.
  final bool isOnboardingCompleted;

  @override
  bool operator ==(Object other) =>
      other is SocialLoginResult &&
      other.isNewUser == isNewUser &&
      other.isConsentRequired == isConsentRequired &&
      other.isGuardianConsentRequired == isGuardianConsentRequired &&
      setEquals(other.missingFields, missingFields) &&
      other.isOnboardingCompleted == isOnboardingCompleted;

  @override
  int get hashCode => Object.hash(
    isNewUser,
    isConsentRequired,
    isGuardianConsentRequired,
    Object.hashAllUnordered(missingFields),
    isOnboardingCompleted,
  );
}
