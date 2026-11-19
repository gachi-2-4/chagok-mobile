import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_repository.dart';
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
  });

  group('InMemoryOnboardingRepository', () {
    test('저장하기 전에는 null을 돌려준다', () async {
      final repository = InMemoryOnboardingRepository();

      expect(await repository.fetch(), isNull);
    });

    test('저장한 답을 다시 불러온다', () async {
      final repository = InMemoryOnboardingRepository();
      const answers = OnboardingAnswers(nationality: Nationality.korean);

      await repository.save(answers);

      final fetched = await repository.fetch();
      expect(fetched?.nationality, Nationality.korean);
    });
  });
}
