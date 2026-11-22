import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/auth/data/auth_failure.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/check_label.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/form_message.dart';
import 'package:flutter/material.dart';

/// A03 약관 동의 화면의 내용. 전화번호 가입과 간편 로그인이 함께 씁니다.
///
/// 상태는 화면마다 다른 Notifier가 가지고, 이 위젯은 받은 값을 그리고 동작을 전달만 합니다.
class TermsAgreementForm extends StatelessWidget {
  const TermsAgreementForm({
    required this.agreedTerms,
    required this.hasAgreedToAll,
    required this.canComplete,
    required this.failure,
    required this.onToggleAll,
    required this.onToggleTerm,
    required this.onComplete,
    super.key,
  });

  /// 동의한 약관.
  final Set<Term> agreedTerms;

  /// 모든 약관에 동의했는지.
  final bool hasAgreedToAll;

  /// "동의하고 완료" 버튼을 누를 수 있는지.
  final bool canComplete;

  /// 마지막 요청이 실패한 이유. 없으면 null.
  final AuthFailure? failure;

  /// "전체 동의"를 눌렀을 때.
  final VoidCallback onToggleAll;

  /// 약관 하나를 눌렀을 때.
  final ValueChanged<Term> onToggleTerm;

  /// "동의하고 완료"를 눌렀을 때.
  final VoidCallback onComplete;

  static const _dividerHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    final failure = this.failure;

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
                isChecked: hasAgreedToAll,
                onTap: onToggleAll,
              ),
              for (final term in Term.values) ...[
                const Divider(height: _dividerHeight, color: AppColors.divider),
                _TermRow(
                  term: term,
                  isAgreed: agreedTerms.contains(term),
                  onToggle: () => onToggleTerm(term),
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
          onPressed: canComplete ? onComplete : null,
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
