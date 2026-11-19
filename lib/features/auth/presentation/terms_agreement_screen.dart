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

  /// 제목 묶음과 약관 카드 사이 간격.
  static const _headerGap = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(signUpProvider);
    final notifier = ref.read(signUpProvider.notifier);
    final errorMessage = form.errorMessage;

    Future<void> complete() async {
      final isCompleted = await notifier.complete();
      if (!isCompleted || !context.mounted) return;
      ref.invalidate(signUpProvider);
      context.go(AppRoute.home);
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
        const SizedBox(height: _headerGap),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CheckLabel(
                label: AuthStrings.agreeToAll,
                isChecked: form.hasAgreedToAll,
                onTap: notifier.toggleAllTerms,
              ),
              for (final term in Term.values) ...[
                const Divider(height: 1, color: AppColors.divider),
                _TermRow(
                  term: term,
                  isAgreed: form.agreedTerms.contains(term),
                  onToggle: () => notifier.toggleTerm(term),
                  onView: () => showTerm(term),
                ),
              ],
            ],
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.stack),
          FormMessage(errorMessage, isError: true),
        ],
      ],
      actions: [
        AppButton.primary(
          label: AuthStrings.agreeAndComplete,
          onPressed: form.canComplete ? complete : null,
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
    final suffix = term.isRequired
        ? AuthStrings.requiredSuffix
        : AuthStrings.optionalSuffix;

    return Row(
      children: [
        Expanded(
          child: CheckLabel(
            label: '${term.title} $suffix',
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
          child: const Text('${AuthStrings.viewTerm} ›'),
        ),
      ],
    );
  }
}
