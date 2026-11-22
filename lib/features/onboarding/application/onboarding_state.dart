import 'package:chagok_mobile/features/onboarding/application/onboarding_step.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/sample_address_regions.dart';

/// 첫 설문 화면의 상태.
class OnboardingState {
  const OnboardingState({
    this.step = OnboardingStep.nationality,
    this.answers = const OnboardingAnswers(),
    this.isSubmitting = false,
    this.hasSubmitFailed = false,
  });

  /// 지금 보고 있는 단계.
  final OnboardingStep step;

  /// 지금까지 고른 답.
  final OnboardingAnswers answers;

  /// 마지막 단계에서 답을 저장하는 중이면 true.
  final bool isSubmitting;

  /// 마지막으로 답을 저장하려다 실패했으면 true.
  final bool hasSubmitFailed;

  /// 첫 단계(국적)면 true. 뒤로 가면 화면을 닫습니다.
  bool get isFirstStep => step == OnboardingStep.values.first;

  /// 마지막 단계(복지)면 true. 다음을 누르면 답을 저장합니다.
  bool get isLastStep => step == OnboardingStep.values.last;

  /// O02 주소 입력값에 맞는 시·도·시·군·구 후보.
  ///
  /// 이미 후보 하나를 그대로 골랐으면 더 보여 주지 않습니다.
  List<String> get addressSuggestions {
    final address = answers.address.trim();
    final suggestions = searchAddressRegions(address);
    return suggestions.contains(address) ? const [] : suggestions;
  }

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

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다.
  OnboardingState copyWith({
    OnboardingStep? step,
    OnboardingAnswers? answers,
    bool? isSubmitting,
    bool? hasSubmitFailed,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasSubmitFailed: hasSubmitFailed ?? this.hasSubmitFailed,
    );
  }
}
