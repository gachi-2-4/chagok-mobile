import 'package:chagok_mobile/features/onboarding/application/onboarding_state.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 첫 설문 상태. 화면을 벗어나면 처음부터 다시 합니다.
final onboardingProvider =
    NotifierProvider.autoDispose<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

/// 첫 설문의 답을 받고 단계를 넘기며, 마지막에 답을 저장합니다.
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void selectNationality(Nationality value) =>
      _updateAnswers((answers) => answers.copyWith(nationality: value));

  void updateAddress(String value) =>
      _updateAnswers((answers) => answers.copyWith(address: value));

  void selectHousingType(HousingType value) =>
      _updateAnswers((answers) => answers.copyWith(housingType: value));

  void selectWelfareStatus(WelfareStatus value) =>
      _updateAnswers((answers) => answers.copyWith(welfareStatus: value));

  /// 다음 단계로 넘어갑니다. 마지막 단계면 답을 저장하고 true를 돌려줍니다.
  Future<bool> next() async {
    if (!state.canProceed) return false;
    if (!state.isLastStep) {
      state = state.copyWith(step: OnboardingStep.values[state.step.index + 1]);
      return false;
    }
    state = state.copyWith(isSubmitting: true);
    await ref.read(onboardingRepositoryProvider).save(state.answers);
    if (ref.mounted) state = state.copyWith(isSubmitting: false);
    return true;
  }

  /// 이전 단계로 돌아갑니다. 첫 단계면 false를 돌려줍니다.
  bool back() {
    if (state.isFirstStep) return false;
    state = state.copyWith(step: OnboardingStep.values[state.step.index - 1]);
    return true;
  }

  void _updateAnswers(
    OnboardingAnswers Function(OnboardingAnswers answers) update,
  ) {
    state = state.copyWith(answers: update(state.answers));
  }
}
