import 'package:chagok_mobile/features/onboarding/data/in_memory_onboarding_repository.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InMemoryOnboardingRepository', () {
    test('저장하기 전에 불러오면 null을 돌려준다', () async {
      final repository = InMemoryOnboardingRepository();

      expect(await repository.fetch(), isNull);
    });

    test('답을 저장하고 불러오면 저장한 답을 돌려준다', () async {
      final repository = InMemoryOnboardingRepository();
      const answers = OnboardingAnswers(nationality: Nationality.korean);

      await repository.save(answers);

      final fetched = await repository.fetch();
      expect(fetched?.nationality, Nationality.korean);
    });
  });
}
