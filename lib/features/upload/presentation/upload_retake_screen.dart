import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/core/widgets/app_document_layout.dart';
import 'package:chagok_mobile/features/upload/application/upload_notifier.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/document_preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// U03 · 사진이 흐려 다시 찍어 달라고 안내하는 화면.
class UploadRetakeScreen extends ConsumerWidget {
  const UploadRetakeScreen({super.key});

  static const _gap = 18.0;
  static const _frameHeight = 180.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(uploadProvider.select((state) => state.isBusy));

    Future<void> pickAgain(UploadSource source) async {
      final isPicked = await ref.read(uploadProvider.notifier).pick(source);
      if (!isPicked || !context.mounted) return;
      context.pushReplacement(AppRoute.uploadConfirm);
    }

    return AppDocumentLayout(
      body: [
        const Text(UploadStrings.retakeTitle, style: AppTypography.pageTitle),
        const SizedBox(height: _gap),
        const AppCard.peach(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  UploadStrings.blurryTitle,
                  style: AppTypography.cardTitle,
                ),
              ),
              SizedBox(height: 10),
              Text(
                UploadStrings.blurryDescription,
                style: AppTypography.pageDescription,
              ),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        DocumentPreviewCard(
          minHeight: _frameHeight,
          child: SizedBox(
            height: _frameHeight - 40,
            child: Center(
              child: Text(
                UploadStrings.frameGuide,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  height: 28.5 / 15,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: _gap),
        for (final (index, tip) in UploadStrings.retakeTips.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          Text(tip, style: AppTypography.body),
        ],
      ],
      actions: [
        AppButton.primary(
          label: UploadStrings.retake,
          onPressed: isBusy ? null : () => pickAgain(UploadSource.camera),
        ),
        AppButton.secondary(
          label: UploadStrings.pickOtherImage,
          onPressed: isBusy ? null : () => pickAgain(UploadSource.album),
        ),
      ],
    );
  }
}
