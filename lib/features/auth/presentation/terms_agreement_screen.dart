import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/auth/application/sign_up_notifier.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/check_label.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A03 · 약관에 동의하고 가입을 마치는 화면.
class TermsAgreementScreen extends ConsumerWidget {
  const TermsAgreementScreen({super.key});

  static const _dividerHeight = 1.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(signUpProvider);
    final failure = form.failure;

    Future<void> complete() async {
      final isCompleted = await ref.read(signUpProvider.notifier).complete();
      if (!isCompleted || !context.mounted) return;
      ref.invalidate(signUpProvider);
      // 가입을 마치면 첫 설문(O01~O04)을 거쳐 홈으로 갑니다.
      context.go(AppRoute.onboarding);
    }

    void showTerm(Term term) {
      // TODO: 약관 본문이 정해지면 상세 화면으로 연결합니다.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AuthStrings.comingSoon)));
    }

    return AuthFormLayout(
      appBar: const AppTopBar(title: AuthStrings.termsBarTitle),
      body: [
        const AppPageHeader(
          title: AuthStrings.termsTitle,
          description: AuthStrings.termsDescription,
        ),
        const SizedBox(height: AppSpacing.pageHeaderBottom),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CheckLabel(
                label: AuthStrings.agreeToAll,
                isChecked: form.hasAgreedToAll,
                onTap: () => ref.read(signUpProvider.notifier).toggleAllTerms(),
              ),
              for (final term in Term.values) ...[
                const Divider(height: _dividerHeight, color: AppColors.divider),
                _TermRow(
                  term: term,
                  isAgreed: form.agreedTerms.contains(term),
                  onToggle: () =>
                      ref.read(signUpProvider.notifier).toggleTerm(term),
                  onView: () => showTerm(term),
                ),
              ],
            ],
          ),
        ),
        if (failure != null) ...[
          const SizedBox(height: AppSpacing.stack),
          FormMessage(text: AuthStrings.failure(failure), isError: true),
        ],
      ],
      actions: [
        AppButton.primary(
          label: AuthStrings.agreeAndComplete,
          onPressed: form.canComplete ? () => unawaited(complete()) : null,
        ),
      ],
    );
  }
}

/// 약관 한 줄. 왼쪽은 동의 표시, 오른쪽은 "보기 ›".
class _TermRow extends StatelessWidget {
  const _TermRow({
    required this.term,
    required this.isAgreed,
    required this.onToggle,
    required this.onView,
  });

  final Term term;
  final bool isAgreed;
  final VoidCallback onToggle;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CheckLabel(
            label: AuthStrings.termLabel(term),
            isChecked: isAgreed,
            onTap: onToggle,
          ),
        ),
        TextButton(
          onPressed: onView,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            textStyle: AppTypography.body,
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            minimumSize: const Size(0, kMinInteractiveDimension),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(AuthStrings.viewTerm),
        ),
      ],
    );
  }
}
