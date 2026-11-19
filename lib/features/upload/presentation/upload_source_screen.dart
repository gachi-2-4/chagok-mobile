import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_page_header.dart';
import 'package:chagok_mobile/features/upload/application/upload_notifier.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/source_option_card.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/upload_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// U01 · 서류를 어떤 방법으로 담을지 고르는 화면.
class UploadSourceScreen extends ConsumerWidget {
  const UploadSourceScreen({super.key});

  /// 제목 묶음과 카드 사이 간격.
  static const _headerGap = 18.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(uploadProvider.select((state) => state.isBusy));

    Future<void> pick(UploadSource source) async {
      final isPicked = await ref.read(uploadProvider.notifier).pick(source);
      if (!isPicked || !context.mounted) return;
      await context.push(AppRoute.uploadConfirm);
    }

    VoidCallback? onPick(UploadSource source) =>
        isBusy ? null : () => pick(source);

    return UploadLayout(
      body: [
        const AppPageHeader(
          title: UploadStrings.sourceTitle,
          description: UploadStrings.sourceDescription,
        ),
        const SizedBox(height: _headerGap),
        SourceOptionCard(
          tone: SourceOptionTone.peach,
          title: UploadStrings.cameraTitle,
          description: UploadStrings.cameraDescription,
          onTap: onPick(UploadSource.camera),
        ),
        const SizedBox(height: AppSpacing.lg),
        SourceOptionCard(
          tone: SourceOptionTone.green,
          title: UploadStrings.albumTitle,
          description: UploadStrings.albumDescription,
          onTap: onPick(UploadSource.album),
        ),
        const SizedBox(height: AppSpacing.lg),
        SourceOptionCard(
          tone: SourceOptionTone.plain,
          title: UploadStrings.pdfTitle,
          description: UploadStrings.pdfDescription,
          onTap: onPick(UploadSource.pdf),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(UploadStrings.sourceNote, style: AppTypography.caption),
      ],
      actions: [
        AppButton.primary(
          label: UploadStrings.pickPdf,
          onPressed: onPick(UploadSource.pdf),
        ),
      ],
    );
  }
}
