import 'package:chagok_mobile/features/onboarding/data/housing_type.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/welfare_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingAnswers', () {
    test('JSON으로 바꿨다가 되돌리면 같은 값이 된다', () {
      const answers = OnboardingAnswers(
        nationality: Nationality.foreigner,
        address: '부산시 해운대구',
        housingType: HousingType.jeonse,
        welfareStatus: WelfareStatus.nearPoverty,
      );

      final restored = OnboardingAnswers.fromJson(answers.toJson());

      expect(restored.toJson(), answers.toJson());
    });

    test('모르는 값이 있으면 그 답은 비워 둔다', () {
      final restored = OnboardingAnswers.fromJson(const {
        'nationality': 'martian',
        'address': null,
      });

      expect(restored.nationality, isNull);
      expect(restored.address, isEmpty);
    });

    test('copyWith로 일부 값을 넘기면 그 값만 바꾸고 나머지는 그대로 둔다', () {
      const answers = OnboardingAnswers(
        nationality: Nationality.korean,
        address: '서울시',
      );

      final updated = answers.copyWith(housingType: HousingType.owned);

      expect(updated.nationality, Nationality.korean);
      expect(updated.address, '서울시');
      expect(updated.housingType, HousingType.owned);
    });
  });
}
