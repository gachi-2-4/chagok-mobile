import 'package:chagok_mobile/features/onboarding/application/onboarding_state.dart';
import 'package:chagok_mobile/features/onboarding/application/onboarding_step.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/welfare_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingState', () {
    test('첫 단계면 isFirstStep만 true다', () {
      const state = OnboardingState();

      expect(state.isFirstStep, isTrue);
      expect(state.isLastStep, isFalse);
    });

    test('마지막 단계면 isLastStep만 true다', () {
      const state = OnboardingState(step: OnboardingStep.welfare);

      expect(state.isFirstStep, isFalse);
      expect(state.isLastStep, isTrue);
    });

    test('지금 단계의 답을 고르면 canProceed가 true다', () {
      const state = OnboardingState(
        answers: OnboardingAnswers(nationality: Nationality.korean),
      );

      expect(state.canProceed, isTrue);
    });

    test('다른 단계의 답만 골랐으면 canProceed가 false다', () {
      const state = OnboardingState(
        step: OnboardingStep.welfare,
        answers: OnboardingAnswers(nationality: Nationality.korean),
      );

      expect(state.canProceed, isFalse);
    });

    test('저장하는 중이면 답을 골랐어도 canProceed가 false다', () {
      const state = OnboardingState(
        step: OnboardingStep.welfare,
        answers: OnboardingAnswers(welfareStatus: WelfareStatus.none),
        isSubmitting: true,
      );

      expect(state.canProceed, isFalse);
    });

    test('copyWith로 일부 값을 넘기면 그 값만 바꾸고 나머지는 그대로 둔다', () {
      const state = OnboardingState(hasSubmitFailed: true);

      final updated = state.copyWith(step: OnboardingStep.address);

      expect(updated.step, OnboardingStep.address);
      expect(updated.hasSubmitFailed, isTrue);
      expect(updated.isSubmitting, isFalse);
    });
  });
}
