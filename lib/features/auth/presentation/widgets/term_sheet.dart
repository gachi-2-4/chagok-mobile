import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/auth/data/term.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:chagok_mobile/features/auth/presentation/term_texts.dart';
import 'package:flutter/material.dart';

/// [term]의 본문을 아래에서 올라오는 시트로 띄웁니다.
Future<void> showTermSheet(BuildContext context, Term term) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (context) => TermSheet(term: term),
  );
}

/// 약관 하나의 제목과 조항을 스크롤해 읽는 시트.
class TermSheet extends StatelessWidget {
  const TermSheet({required this.term, super.key});

  final Term term;

  /// 화면 높이에 대한 시트 최대 높이 비율.
  static const _maxHeightFactor = 0.75;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          0,
          AppSpacing.screenHorizontal,
          AppSpacing.actionsBottom,
        ),
        children: [
          Text(AuthStrings.term(term), style: AppTypography.sheetTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            TermTexts.draftNotice,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          for (final clause in TermTexts.of(term)) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(clause.title, style: AppTypography.listTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(
              clause.body,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
