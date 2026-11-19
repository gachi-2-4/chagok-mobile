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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// U04 · 서류에서 읽어 낸 조건을 확인하고 보관하는 화면.
class UploadReviewScreen extends ConsumerWidget {
  const UploadReviewScreen({super.key});

  static const _gap = 18.0;

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

    void edit() {
      // TODO: 서류 내용 수정 화면(D01)이 생기면 연결합니다.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(UploadStrings.comingSoon)));
    }

    final uncertain = result.uncertainFields;
    final renamed = result.renamedFields;

    return AppDocumentLayout(
      body: [
        const Text(UploadStrings.reviewTitle, style: AppTypography.pageTitle),
        const SizedBox(height: _gap),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppChip(label: result.documentType, isSelected: true),
            AppChip(label: UploadStrings.pageCount(result.pageCount)),
          ],
        ),
        const SizedBox(height: _gap),
        const Text(
          UploadStrings.reviewDescription,
          style: AppTypography.pageDescription,
        ),
        const SizedBox(height: _gap),
        AppCard(child: _FieldTable(fields: result.fields)),
        for (final field in uncertain) ...[
          const SizedBox(height: _gap),
          AppCard.peach(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  UploadStrings.uncertainNotice(field.label),
                  style: AppTypography.body,
                ),
                const SizedBox(height: 9),
                const Text(
                  UploadStrings.uncertainHelp,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
        for (final field in renamed) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            UploadStrings.renamedNote(field.originalLabel ?? '', field.label),
            style: AppTypography.caption,
          ),
        ],
      ],
      actions: [
        AppButton.primary(
          label: UploadStrings.saveDocument,
          onPressed: state.canSave ? save : null,
        ),
        AppButton.secondary(
          label: UploadStrings.editDocument,
          onPressed: state.isBusy ? null : edit,
        ),
      ],
    );
  }
}

/// 조건 이름 · 값 표. 확실히 읽은 조건 아래에 줄을 긋고 확인이 필요한 조건을 둡니다.
class _FieldTable extends StatelessWidget {
  const _FieldTable({required this.fields});

  final List<ExtractedField> fields;

  @override
  Widget build(BuildContext context) {
    final certain = fields.where((field) => !field.isUncertain).toList();
    final uncertain = fields.where((field) => field.isUncertain).toList();

    Widget row(ExtractedField field) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(field.label, style: AppTypography.body)),
        const SizedBox(width: AppSpacing.md),
        Text(
          field.value ?? UploadStrings.needsCheck,
          style: AppTypography.body,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, field) in certain.indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          row(field),
        ],
        if (certain.isNotEmpty && uncertain.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.divider),
          ),
        for (final (index, field) in uncertain.indexed) ...[
          if (index > 0) const SizedBox(height: 10),
          row(field),
        ],
      ],
    );
  }
}
