import 'package:chagok_mobile/features/onboarding/application/onboarding_notifier.dart';
import 'package:chagok_mobile/features/onboarding/application/onboarding_state.dart';
import 'package:chagok_mobile/features/onboarding/application/onboarding_step.dart';
import 'package:chagok_mobile/features/onboarding/data/housing_type.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_repository.dart';
import 'package:chagok_mobile/features/onboarding/data/welfare_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_onboarding_repository.dart';

void main() {
  late FakeOnboardingRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeOnboardingRepository();
    container = ProviderContainer(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(onboardingProvider, (_, _) {});
  });

  OnboardingNotifier notifier() => container.read(onboardingProvider.notifier);
  OnboardingState state() => container.read(onboardingProvider);

  Future<void> answerAll() async {
    notifier().selectNationality(Nationality.korean);
    await notifier().next();
    notifier().updateAddress('서울시 마포구 월드컵북로 21');
    await notifier().next();
    notifier().selectHousingType(HousingType.monthlyRent);
    await notifier().next();
    notifier().selectWelfareStatus(WelfareStatus.none);
  }

  group('OnboardingNotifier', () {
    test('처음 읽으면 국적 단계에서 시작한다', () {
      expect(state().step, OnboardingStep.nationality);
      expect(state().isFirstStep, isTrue);
    });

    test('답을 고르지 않으면 다음 단계로 넘어가지 않는다', () async {
      await notifier().next();

      expect(state().step, OnboardingStep.nationality);
    });

    test('답을 고르고 다음을 누르면 다음 단계로 넘어간다', () async {
      notifier().selectNationality(Nationality.foreigner);

      final isCompleted = await notifier().next();

      expect(isCompleted, isFalse);
      expect(state().step, OnboardingStep.address);
    });

    test('주소가 공백뿐이면 다음 단계로 넘어갈 수 없다', () async {
      notifier().selectNationality(Nationality.korean);
      await notifier().next();

      notifier().updateAddress('   ');

      expect(state().canProceed, isFalse);
    });

    test('이전 단계로 돌아가면 앞에서 고른 답은 그대로 남아 있다', () async {
      notifier().selectNationality(Nationality.foreigner);
      await notifier().next();

      final didGoBack = notifier().back();

      expect(didGoBack, isTrue);
      expect(state().step, OnboardingStep.nationality);
      expect(state().answers.nationality, Nationality.foreigner);
    });

    test('첫 단계에서 뒤로 가면 false를 돌려준다', () {
      expect(notifier().back(), isFalse);
    });

    test('마지막 단계에서 다음을 누르면 답을 저장하고 true를 돌려준다', () async {
      await answerAll();

      final isCompleted = await notifier().next();

      expect(isCompleted, isTrue);
      expect(repository.saved?.toJson(), {
        'nationality': 'korean',
        'address': '서울시 마포구 월드컵북로 21',
        'housingType': 'monthlyRent',
        'welfareStatus': 'none',
      });
    });

    test('답을 저장하지 못하면 저장 중 상태를 풀고 실패를 표시한다', () async {
      await answerAll();
      repository.saveError = Exception('network');

      final isCompleted = await notifier().next();

      expect(isCompleted, isFalse);
      expect(state().isSubmitting, isFalse);
      expect(state().hasSubmitFailed, isTrue);
      expect(state().step, OnboardingStep.welfare);
    });

    test('실패한 뒤 다시 저장해 성공하면 실패 표시가 사라진다', () async {
      await answerAll();
      repository.saveError = Exception('network');
      await notifier().next();

      repository.saveError = null;
      final isCompleted = await notifier().next();

      expect(isCompleted, isTrue);
      expect(state().hasSubmitFailed, isFalse);
    });
  });
}
