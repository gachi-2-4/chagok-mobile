import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/features/archive/application/plain_language_notifier.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/sheet_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류 [documentId]를 AI로 쉬운 말로 바꾼 설명을 아래에서 띄웁니다.
Future<void> showPlainLanguageSheet(
  BuildContext context, {
  required String documentId,
  required String documentTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    // 보관함 탭 안에서 열어도 하단 탭 바까지 덮도록 가장 바깥 Navigator에 띄웁니다.
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
    ),
    builder: (context) => PlainLanguageSheet(
      documentId: documentId,
      documentTitle: documentTitle,
    ),
  );
}

/// 쉬운 말로 바꾼 서류 설명 시트. 바꾸는 중·실패·설명 상태를 모두 보여 줍니다.
class PlainLanguageSheet extends ConsumerWidget {
  const PlainLanguageSheet({
    required this.documentId,
    required this.documentTitle,
    super.key,
  });

  /// 바꿀 서류 id.
  final String documentId;

  /// 시트 위에 보여 줄 서류 이름. 예: "전세 임대차 계약서"
  final String documentTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.sheetHandleTop,
          AppSpacing.screenHorizontal,
          AppSpacing.actionsBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: SheetHandle()),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              ArchiveStrings.plainLanguageTitle,
              style: AppTypography.sheetTitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              documentTitle,
              style: AppTypography.listSubtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.block),
            ref
                .watch(plainLanguageProvider(documentId))
                .when(
                  data: (text) => _Explanation(text: text),
                  loading: () => const _Translating(),
                  error: (error, stackTrace) => _TranslateError(
                    onRetry: () =>
                        ref.invalidate(plainLanguageProvider(documentId)),
                  ),
                ),
            const SizedBox(height: AppSpacing.sectionGapLarge),
            AppButton.secondary(
              label: ArchiveStrings.close,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 긴 설명도 화면 위쪽이 조금 보이게 시트 높이를 화면의 이 비율로 제한합니다.
  static const _maxHeightFactor = 0.85;
}

/// 쉬운 말 설명과 AI 안내.
class _Explanation extends StatelessWidget {
  const _Explanation({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.softFill,
            borderRadius: BorderRadius.circular(AppRadius.paper),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Text(text, style: AppTypography.body),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(ArchiveStrings.aiNotice, style: AppTypography.caption),
      ],
    );
  }
}

/// 쉬운 말로 바꾸는 동안 보여 주는 안내.
class _Translating extends StatelessWidget {
  const _Translating();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.lg),
          Text(ArchiveStrings.translating, style: AppTypography.listSubtitle),
        ],
      ),
    );
  }
}

/// 쉬운 말로 바꾸지 못했을 때의 안내와 다시 시도 버튼.
class _TranslateError extends StatelessWidget {
  const _TranslateError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          ArchiveStrings.translateFailed,
          textAlign: TextAlign.center,
          style: AppTypography.body,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton.primary(label: ArchiveStrings.retry, onPressed: onRetry),
      ],
    );
  }
}
