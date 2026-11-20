import 'package:chagok_mobile/features/onboarding/application/onboarding_state.dart';
import 'package:chagok_mobile/features/onboarding/application/onboarding_step.dart';
import 'package:chagok_mobile/features/onboarding/data/housing_type.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_repository.dart';
import 'package:chagok_mobile/features/onboarding/data/welfare_status.dart';
import 'package:flutter/foundation.dart';
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

  /// O01 국적을 고릅니다.
  void selectNationality(Nationality value) =>
      _updateAnswers((answers) => answers.copyWith(nationality: value));

  /// O02 주소 입력값을 바꿉니다.
  void updateAddress(String value) =>
      _updateAnswers((answers) => answers.copyWith(address: value));

  /// O03 주거 형태를 고릅니다.
  void selectHousingType(HousingType value) =>
      _updateAnswers((answers) => answers.copyWith(housingType: value));

  /// O04 받고 있는 복지를 고릅니다.
  void selectWelfareStatus(WelfareStatus value) =>
      _updateAnswers((answers) => answers.copyWith(welfareStatus: value));

  /// 다음 단계로 넘어갑니다. 마지막 단계면 답을 저장하고 true를 돌려줍니다.
  ///
  /// 저장하지 못하면 [OnboardingState.hasSubmitFailed]를 켜고 false를 돌려줍니다.
  Future<bool> next() async {
    if (!state.canProceed) return false;
    if (!state.isLastStep) {
      state = state.copyWith(step: OnboardingStep.values[state.step.index + 1]);
      return false;
    }
    state = state.copyWith(isSubmitting: true, hasSubmitFailed: false);
    try {
      await ref.read(onboardingRepositoryProvider).save(state.answers);
      if (ref.mounted) state = state.copyWith(isSubmitting: false);
      return true;
    } catch (error, stackTrace) {
      debugPrint('첫 설문 답을 저장하지 못했습니다: $error\n$stackTrace');
      if (ref.mounted) {
        state = state.copyWith(isSubmitting: false, hasSubmitFailed: true);
      }
      return false;
    }
  }

  /// 이전 단계로 돌아갑니다. 첫 단계면 false를 돌려줍니다.
  ///
  /// 답을 저장하는 중이면 단계를 바꾸지 않고 true를 돌려줍니다. 화면을 닫지
  /// 않고, 저장한 답과 화면의 답이 달라지지 않게 합니다.
  bool back() {
    if (state.isSubmitting) return true;
    if (state.isFirstStep) return false;
    state = state.copyWith(step: OnboardingStep.values[state.step.index - 1]);
    return true;
  }

  /// 답을 바꿉니다. 저장하는 중에는 저장한 답과 달라지지 않도록 무시합니다.
  void _updateAnswers(
    OnboardingAnswers Function(OnboardingAnswers answers) update,
  ) {
    if (state.isSubmitting) return;
    state = state.copyWith(answers: update(state.answers));
  }
}
