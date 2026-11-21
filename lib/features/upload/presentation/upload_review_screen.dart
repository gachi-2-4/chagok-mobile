import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/core/widgets/app_chip.dart';
import 'package:chagok_mobile/core/widgets/app_document_layout.dart';
import 'package:chagok_mobile/features/upload/application/upload_notifier.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/extracted_field.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/upload_failure_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// U04 · 서류에서 읽어 낸 조건을 확인하고 보관하는 화면.
class UploadReviewScreen extends ConsumerWidget {
  const UploadReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadProvider);
    final result = state.result;

    if (result is! AnalysisSucceeded) {
      return const AppDocumentLayout(body: [], actions: []);
    }

    Future<void> save() async {
      final isSaved = await ref.read(uploadProvider.notifier).save();
      if (!isSaved || !context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(UploadStrings.saved)));
      context.go(AppRoute.home);
    }

    // 서버가 서류를 만든 뒤라 id가 있으면 그 서류의 내용 수정(D01)으로 갑니다.
    final documentId = result.documentId;

    return AppDocumentLayout(
      body: [
        const Text(UploadStrings.reviewTitle, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.block),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppChip(label: result.documentType, isSelected: true),
            AppChip(label: UploadStrings.pageCount(result.pageCount)),
          ],
        ),
        const SizedBox(height: AppSpacing.block),
        const Text(
          UploadStrings.reviewDescription,
          style: AppTypography.pageDescription,
        ),
        const SizedBox(height: AppSpacing.block),
        AppCard(child: _FieldTable(fields: result.fields)),
        _ReviewNotes(result: result),
        if (state.hasFailed) ...[
          const SizedBox(height: AppSpacing.lg),
          const UploadFailureNotice(),
        ],
      ],
      actions: [
        AppButton.primary(
          label: UploadStrings.saveDocument,
          onPressed: state.canSave ? () => unawaited(save()) : null,
        ),
        AppButton.secondary(
          label: UploadStrings.editDocument,
          onPressed: state.isBusy || documentId == null
              ? null
              : () =>
                    unawaited(context.push(AppRoute.documentEdit(documentId))),
        ),
      ],
    );
  }
}

/// 확실히 읽지 못한 조건 안내 카드와, 이름을 바꿔 정리한 조건 안내.
class _ReviewNotes extends StatelessWidget {
  const _ReviewNotes({required this.result});

  final AnalysisSucceeded result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in result.uncertainFields) ...[
          const SizedBox(height: AppSpacing.block),
          AppCard.peach(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  UploadStrings.uncertainNotice(field.label),
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.noticeHelpGap),
                const Text(
                  UploadStrings.uncertainHelp,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
        for (final field in result.renamedFields) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            UploadStrings.renamedNote(field.originalLabel ?? '', field.label),
            style: AppTypography.caption,
          ),
        ],
      ],
    );
  }
}

/// 조건 이름 · 값 표. 확실히 읽은 조건 아래에 줄을 긋고 확인이 필요한 조건을 둡니다.
class _FieldTable extends StatelessWidget {
  const _FieldTable({required this.fields});

  final List<ExtractedField> fields;

  static const _dividerHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    final certain = fields.where((field) => !field.isUncertain).toList();
    final uncertain = fields.where((field) => field.isUncertain).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, field) in certain.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.tableRowGap),
          _FieldRow(field: field),
        ],
        if (certain.isNotEmpty && uncertain.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.tableDividerGap),
            child: Divider(height: _dividerHeight, color: AppColors.divider),
          ),
        for (final (index, field) in uncertain.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.tableRowGap),
          _FieldRow(field: field),
        ],
      ],
    );
  }
}

/// 표의 한 줄. 왼쪽은 조건 이름, 오른쪽은 값 또는 "확인 필요".
class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.field});

  final ExtractedField field;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(field.label, style: AppTypography.body)),
        const SizedBox(width: AppSpacing.md),
        // 특약처럼 긴 값도 표 밖으로 넘치지 않고 줄을 바꾸도록 너비를 제한합니다.
        Flexible(
          child: Text(
            field.value ?? UploadStrings.needsCheck,
            textAlign: TextAlign.right,
            style: AppTypography.body,
          ),
        ),
      ],
    );
  }
}
