import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/features/upload/application/upload_notifier.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/document_preview_card.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/upload_failure_notice.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/upload_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// U03 · 사진이 흐려 다시 찍어 달라고 안내하는 화면.
class UploadRetakeScreen extends ConsumerWidget {
  const UploadRetakeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (isBusy, hasFailed) = ref.watch(
      uploadProvider.select((state) => (state.isBusy, state.hasFailed)),
    );

    Future<void> pickAgain(UploadSource source) async {
      final isPicked = await ref.read(uploadProvider.notifier).pick(source);
      if (!isPicked || !context.mounted) return;
      context.pushReplacement(AppRoute.uploadConfirm);
    }

    return UploadLayout(
      body: [
        const Text(UploadStrings.retakeTitle, style: AppTypography.pageTitle),
        const SizedBox(height: AppSpacing.block),
        const _BlurryNotice(),
        const SizedBox(height: AppSpacing.block),
        const _FrameGuide(),
        const SizedBox(height: AppSpacing.block),
        for (final (index, tip) in UploadStrings.retakeTips.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          Text(tip, style: AppTypography.body),
        ],
        if (hasFailed) ...[
          const SizedBox(height: AppSpacing.lg),
          const UploadFailureNotice(),
        ],
      ],
      actions: [
        AppButton.primary(
          label: UploadStrings.retake,
          onPressed: isBusy
              ? null
              : () => unawaited(pickAgain(UploadSource.camera)),
        ),
        AppButton.secondary(
          label: UploadStrings.pickOtherImage,
          onPressed: isBusy
              ? null
              : () => unawaited(pickAgain(UploadSource.album)),
        ),
      ],
    );
  }
}

/// "일부 글자가 흐릿해요" 살구색 안내 카드.
class _BlurryNotice extends StatelessWidget {
  const _BlurryNotice();

  @override
  Widget build(BuildContext context) {
    return const AppCard.peach(
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
          SizedBox(height: AppSpacing.cardTitleGap),
          Text(
            UploadStrings.blurryDescription,
            style: AppTypography.pageDescription,
          ),
        ],
      ),
    );
  }
}

/// 서류 네 모서리를 맞추라는 촬영 틀.
class _FrameGuide extends StatelessWidget {
  const _FrameGuide();

  static const _frameHeight = 180.0;

  @override
  Widget build(BuildContext context) {
    return const DocumentPreviewCard(
      minHeight: _frameHeight,
      child: SizedBox(
        // 미리 보기 상자의 위아래 안쪽 여백을 뺀 높이에서 안내를 가운데에 둡니다.
        height: _frameHeight - 2 * AppSpacing.xl,
        child: Center(
          child: Text(
            UploadStrings.frameGuide,
            textAlign: TextAlign.center,
            style: AppTypography.frameGuide,
          ),
        ),
      ),
    );
  }
}
