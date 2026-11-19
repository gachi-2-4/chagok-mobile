import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/onboarding/application/onboarding_notifier.dart';
import 'package:chagok_mobile/features/onboarding/application/onboarding_state.dart';
import 'package:chagok_mobile/features/onboarding/data/onboarding_answers.dart';
import 'package:chagok_mobile/features/onboarding/presentation/onboarding_strings.dart';
import 'package:chagok_mobile/features/onboarding/presentation/widgets/choice_tile.dart';
import 'package:chagok_mobile/features/onboarding/presentation/widgets/step_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// O01~O04 · 가입 직후 생활 정보를 묻는 첫 설문 화면.
///
/// 네 단계를 한 화면 안에서 바꿔 보여 줍니다. 뒤로 가기를 누르면
/// 이전 단계로 돌아가고, 첫 단계에서는 화면을 닫습니다.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  /// Figma `div.main` 위 여백.
  static const _bodyTop = 12.0;

  /// 진행 막대와 제목 사이 간격.
  static const _progressGap = 18.0;

  /// 제목 묶음과 선택지 사이 간격.
  static const _headerGap = 24.0;

  /// Figma `div.actions` 위·아래 여백.
  static const _actionsTop = 18.0;
  static const _actionsBottom = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final step = state.step;

    Future<void> next() async {
      final isCompleted = await notifier.next();
      if (!isCompleted || !context.mounted) return;
      context.go(AppRoute.home);
    }

    void back() {
      if (!notifier.back()) Navigator.maybePop(context);
    }

    final (title, description) = switch (step) {
      OnboardingStep.nationality => (
        OnboardingStrings.nationalityTitle,
        OnboardingStrings.nationalityDescription,
      ),
      OnboardingStep.address => (
        OnboardingStrings.addressTitle,
        OnboardingStrings.addressDescription,
      ),
      OnboardingStep.housingType => (
        OnboardingStrings.housingTypeTitle,
        OnboardingStrings.housingTypeDescription,
      ),
      OnboardingStep.welfare => (
        OnboardingStrings.welfareTitle,
        OnboardingStrings.welfareDescription,
      ),
    };

    return PopScope(
      canPop: state.isFirstStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) notifier.back();
      },
      child: Scaffold(
        appBar: AppTopBar(title: OnboardingStrings.barTitle, onBack: back),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    _bodyTop,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xl,
                  ),
                  children: [
                    StepProgress(
                      current: step.index + 1,
                      total: OnboardingStep.values.length,
                      semanticLabel: OnboardingStrings.progress(
                        step.index + 1,
                        OnboardingStep.values.length,
                      ),
                    ),
                    const SizedBox(height: _progressGap),
                    AppPageHeader(title: title, description: description),
                    const SizedBox(height: _headerGap),
                    switch (step) {
                      OnboardingStep.address => _AddressStep(
                        initialValue: state.answers.address,
                        onChanged: notifier.updateAddress,
                      ),
                      _ => _ChoiceList(state: state, notifier: notifier),
                    },
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  _actionsTop,
                  AppSpacing.screenHorizontal,
                  _actionsBottom,
                ),
                child: AppButton.primary(
                  label: state.isLastStep
                      ? OnboardingStrings.complete
                      : OnboardingStrings.next,
                  onPressed: state.canProceed ? next : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 지금 단계의 선택지 목록.
class _ChoiceList extends StatelessWidget {
  const _ChoiceList({required this.state, required this.notifier});

  final OnboardingState state;
  final OnboardingNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final answers = state.answers;
    final tiles = switch (state.step) {
      OnboardingStep.nationality => [
        for (final value in Nationality.values)
          ChoiceTile(
            label: OnboardingStrings.nationality(value),
            isSelected: answers.nationality == value,
            onTap: () => notifier.selectNationality(value),
          ),
      ],
      OnboardingStep.housingType => [
        for (final value in HousingType.values)
          ChoiceTile(
            label: OnboardingStrings.housingType(value),
            isSelected: answers.housingType == value,
            onTap: () => notifier.selectHousingType(value),
          ),
      ],
      OnboardingStep.welfare => [
        for (final value in WelfareStatus.values)
          ChoiceTile(
            label: OnboardingStrings.welfareStatus(value),
            isSelected: answers.welfareStatus == value,
            onTap: () => notifier.selectWelfareStatus(value),
          ),
      ],
      OnboardingStep.address => const <Widget>[],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, tile) in tiles.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.stack),
          tile,
        ],
      ],
    );
  }
}

/// 도로명주소 입력 단계. 이전 단계에서 돌아와도 입력한 값을 유지합니다.
class _AddressStep extends StatefulWidget {
  const _AddressStep({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_AddressStep> createState() => _AddressStepState();
}

class _AddressStepState extends State<_AddressStep> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 주소 검색 API가 정해지면 검색 결과에서 고르게 바꿉니다.
    return AppTextField(
      label: OnboardingStrings.addressLabel,
      hintText: OnboardingStrings.addressHint,
      controller: _controller,
      onChanged: widget.onChanged,
      keyboardType: TextInputType.streetAddress,
      textInputAction: TextInputAction.done,
    );
  }
}
