import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/onboarding/application/onboarding_notifier.dart';
import 'package:chagok_mobile/features/onboarding/application/onboarding_state.dart';
import 'package:chagok_mobile/features/onboarding/application/onboarding_step.dart';
import 'package:chagok_mobile/features/onboarding/data/housing_type.dart';
import 'package:chagok_mobile/features/onboarding/data/nationality.dart';
import 'package:chagok_mobile/features/onboarding/data/welfare_status.dart';
import 'package:chagok_mobile/features/onboarding/presentation/onboarding_strings.dart';
import 'package:chagok_mobile/features/onboarding/presentation/widgets/choice_tile.dart';
import 'package:chagok_mobile/features/onboarding/presentation/widgets/step_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// O01~O04 · 가입 직후 생활 정보를 묻는 첫 설문 화면.
///
/// 네 단계를 한 화면 안에서 바꿔 보여 줍니다. 뒤로 가기를 누르면
/// 이전 단계로 돌아가고, 첫 단계에서는 화면을 닫습니다. 닫을 이전 화면이 없으면
/// 홈으로 갑니다.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    Future<void> next() async {
      final isCompleted = await ref.read(onboardingProvider.notifier).next();
      if (!isCompleted || !context.mounted) return;
      context.go(AppRoute.home);
    }

    void back() {
      if (ref.read(onboardingProvider.notifier).back()) return;
      // 가입 직후처럼 go로 바로 열리면 닫을 이전 화면이 없으므로 홈으로 보냅니다.
      if (Navigator.canPop(context)) {
        unawaited(Navigator.maybePop(context));
      } else {
        context.go(AppRoute.home);
      }
    }

    return PopScope(
      // 기기 뒤로 가기도 화면 위 버튼과 같게 처리합니다. 첫 단계라도 닫을 이전
      // 화면이 없으면 시스템 pop을 막아, 앱이 닫히지 않고 back()이 홈으로 보냅니다.
      canPop: state.isFirstStep && Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: Scaffold(
        appBar: AppTopBar(title: OnboardingStrings.barTitle, onBack: back),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(child: _StepBody(state: state)),
              _OnboardingActions(state: state, onNext: () => unawaited(next())),
            ],
          ),
        ),
      ),
    );
  }
}

/// 진행 막대, 단계 제목, 단계별 입력을 위에서부터 쌓은 목록.
class _StepBody extends ConsumerWidget {
  const _StepBody({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = state.step;
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
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
        const SizedBox(height: AppSpacing.block),
        AppPageHeader(title: title, description: description),
        const SizedBox(height: AppSpacing.pageHeaderBottom),
        switch (step) {
          OnboardingStep.address => _AddressStep(
            initialValue: state.answers.address,
            onChanged: (value) =>
                ref.read(onboardingProvider.notifier).updateAddress(value),
          ),
          _ => _ChoiceList(state: state),
        },
      ],
    );
  }
}

/// 저장 실패 안내와 "다음"·"완료" 버튼.
class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({required this.state, required this.onNext});

  final OnboardingState state;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.block,
        AppSpacing.screenHorizontal,
        AppSpacing.actionsBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.hasSubmitFailed) ...[
            Text(
              OnboardingStrings.submitFailed,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: AppSpacing.buttonGap),
          ],
          AppButton.primary(
            label: state.isLastStep
                ? OnboardingStrings.complete
                : OnboardingStrings.next,
            onPressed: state.canProceed ? onNext : null,
          ),
        ],
      ),
    );
  }
}

/// 지금 단계의 선택지 목록.
class _ChoiceList extends ConsumerWidget {
  const _ChoiceList({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    OnboardingNotifier notifier() => ref.read(onboardingProvider.notifier);
    final answers = state.answers;
    final tiles = switch (state.step) {
      OnboardingStep.nationality => [
        for (final value in Nationality.values)
          ChoiceTile(
            label: OnboardingStrings.nationality(value),
            isSelected: answers.nationality == value,
            onTap: () => notifier().selectNationality(value),
          ),
      ],
      OnboardingStep.housingType => [
        for (final value in HousingType.values)
          ChoiceTile(
            label: OnboardingStrings.housingType(value),
            isSelected: answers.housingType == value,
            onTap: () => notifier().selectHousingType(value),
          ),
      ],
      OnboardingStep.welfare => [
        for (final value in WelfareStatus.values)
          ChoiceTile(
            label: OnboardingStrings.welfareStatus(value),
            isSelected: answers.welfareStatus == value,
            onTap: () => notifier().selectWelfareStatus(value),
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
