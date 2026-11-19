import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';

/// 첫 설문의 단계. 화면 순서와 같습니다.
enum OnboardingStep { nationality, address, housingType, welfare }

/// 첫 설문 화면의 상태.
class OnboardingState {
  const OnboardingState({
    this.step = OnboardingStep.nationality,
    this.answers = const OnboardingAnswers(),
    this.isSubmitting = false,
  });

  final OnboardingStep step;
  final OnboardingAnswers answers;
  final bool isSubmitting;

  bool get isFirstStep => step == OnboardingStep.values.first;

  bool get isLastStep => step == OnboardingStep.values.last;

  /// 지금 단계의 답을 골라 다음으로 넘어갈 수 있으면 true.
  bool get canProceed {
    if (isSubmitting) return false;
    return switch (step) {
      OnboardingStep.nationality => answers.nationality != null,
      OnboardingStep.address => answers.address.trim().isNotEmpty,
      OnboardingStep.housingType => answers.housingType != null,
      OnboardingStep.welfare => answers.welfareStatus != null,
    };
  }

  OnboardingState copyWith({
    OnboardingStep? step,
    OnboardingAnswers? answers,
    bool? isSubmitting,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
