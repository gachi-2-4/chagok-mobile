import 'dart:async';
import 'dart:typed_data';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/core/widgets/app_document_layout.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/features/upload/application/upload_notifier.dart';
import 'package:chagok_mobile/features/upload/application/upload_state.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/document_box.dart';
import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/document_preview_card.dart';
import 'package:chagok_mobile/features/upload/presentation/widgets/upload_failure_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// U02 · 고른 파일과 보관할 곳을 확인하고 분석을 시작하는 화면.
class UploadConfirmScreen extends ConsumerWidget {
  const UploadConfirmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadProvider);
    final document = state.document;

    if (document == null) {
      // 앱을 다시 열어 상태가 비었으면 처음 화면으로 돌려보냅니다.
      return const AppDocumentLayout(body: [], actions: []);
    }

    Future<void> analyze() async {
      final result = await ref.read(uploadProvider.notifier).analyze();
      if (!context.mounted) return;
      switch (result) {
        case AnalysisSucceeded():
          context.pushReplacement(AppRoute.uploadReview);
        case AnalysisUnclear():
          context.pushReplacement(AppRoute.uploadRetake);
        case null:
          break;
      }
    }

    Future<void> pickOther() async {
      final source = document.isPdf ? UploadSource.pdf : UploadSource.album;
      await ref.read(uploadProvider.notifier).pick(source);
    }

    return PopScope(
      // 분석 실패 안내는 이 화면의 일이라, 첫 화면으로 돌아갈 때 지웁니다.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) ref.read(uploadProvider.notifier).clearFailure();
      },
      child: AppDocumentLayout(
        body: [
          const Text(
            UploadStrings.confirmTitle,
            style: AppTypography.pageTitle,
          ),
          const SizedBox(height: AppSpacing.block),
          _ConfirmDetails(state: state, document: document),
        ],
        actions: [
          // 미리 보기가 길어도 보이도록 실패 안내는 버튼 바로 위에 둡니다.
          if (state.hasFailed) const UploadFailureNotice(),
          AppButton.primary(
            label: state.isBusy
                ? UploadStrings.analyzing
                : UploadStrings.startAnalysis,
            onPressed: state.canAnalyze ? () => unawaited(analyze()) : null,
          ),
          AppButton.secondary(
            label: UploadStrings.pickOtherFile,
            onPressed: state.isBusy ? null : () => unawaited(pickOther()),
          ),
        ],
      ),
    );
  }
}

/// 파일 카드, 보관할 곳, PDF 안내, 첫 페이지 미리 보기.
///
/// 미리 보기는 길어질 수 있어, 골라야 하는 보관할 곳을 그 위에 둡니다.
class _ConfirmDetails extends ConsumerWidget {
  const _ConfirmDetails({required this.state, required this.document});

  final UploadState state;
  final PickedDocument document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FileCard(document: document, boxName: state.selectedBox?.name),
        const SizedBox(height: AppSpacing.block),
        _BoxField(
          state: state,
          onSelected: (boxId) =>
              ref.read(uploadProvider.notifier).selectBox(boxId),
        ),
        if (document.isPdf) ...[
          const SizedBox(height: AppSpacing.lg),
          const Text(
            UploadStrings.pdfPasswordNote,
            style: AppTypography.caption,
          ),
        ],
        const SizedBox(height: AppSpacing.block),
        _PreviewCard(document: document),
      ],
    );
  }
}

/// 파일 종류 · 페이지 수 · 이름 · 보관함을 보여 주는 카드.
class _FileCard extends StatelessWidget {
  const _FileCard({required this.document, required this.boxName});

  final PickedDocument document;
  final String? boxName;

  @override
  Widget build(BuildContext context) {
    final boxName = this.boxName;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                document.isPdf
                    ? UploadStrings.pdfLabel
                    : UploadStrings.imageLabel,
                style: AppTypography.body,
              ),
              if (document.pageCount case final pageCount?)
                Text(
                  UploadStrings.pageCount(pageCount),
                  style: AppTypography.body,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.cardTitleGap),
          Text(document.fileName, style: AppTypography.cardTitle),
          if (boxName != null) ...[
            const SizedBox(height: AppSpacing.cardTitleGap),
            Text(
              UploadStrings.boxSuffix(boxName),
              style: AppTypography.caption,
            ),
          ],
        ],
      ),
    );
  }
}

/// 서류 첫 페이지 미리 보기.
///
/// 예시 서류는 첫 페이지를 옮긴 글을, 찍거나 고른 사진은 첫 쪽 사진을 보여 줍니다.
/// 기기에서 고른 PDF는 내용을 분석하면서 읽으므로 안내만 둡니다.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.document});

  final PickedDocument document;

  @override
  Widget build(BuildContext context) {
    final firstFile = document.files.firstOrNull;

    return DocumentPreviewCard(
      child: switch ((document.preview, firstFile)) {
        (final preview?, _) => _TextPreview(
          preview: preview,
          pageCount: document.pageCount,
        ),
        (null, final file?) when !document.isPdf => _ImagePreview(
          bytes: file.bytes,
          pageCount: document.pageCount,
        ),
        _ => const _PdfPreview(),
      },
    );
  }
}

/// 예시 서류의 첫 페이지를 옮긴 글.
class _TextPreview extends StatelessWidget {
  const _TextPreview({required this.preview, required this.pageCount});

  final DocumentPreview preview;
  final int? pageCount;

  static const _dividerHeight = 1.0;

  @override
  Widget build(BuildContext context) {
    final pageCount = this.pageCount;
    const divider = Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Divider(height: _dividerHeight, color: AppColors.divider),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          preview.title,
          textAlign: TextAlign.center,
          style: AppTypography.previewTitle,
        ),
        divider,
        Text(preview.section, style: AppTypography.caption),
        for (final line in preview.lines) Text(line, style: AppTypography.body),
        if (pageCount != null) ...[
          divider,
          Text(
            UploadStrings.previewPage(1, pageCount),
            style: AppTypography.caption,
          ),
        ],
      ],
    );
  }
}

/// 찍거나 고른 첫 쪽 사진.
class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.bytes, required this.pageCount});

  final Uint8List bytes;
  final int? pageCount;

  /// 사진이 너무 길어 화면을 다 차지하지 않도록 둔 최대 높이.
  static const _maxHeight = 360.0;

  @override
  Widget build(BuildContext context) {
    final pageCount = this.pageCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: _maxHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              semanticLabel: UploadStrings.scannedPageLabel,
              // 사진을 읽지 못하면 빈 자리 대신 PDF와 같은 안내 자리를 둡니다.
              errorBuilder: (context, error, stackTrace) => const _PdfPreview(),
            ),
          ),
        ),
        if (pageCount != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            UploadStrings.previewPage(1, pageCount),
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
        ],
      ],
    );
  }
}

/// 기기에서 고른 PDF의 미리 보기 자리.
class _PdfPreview extends StatelessWidget {
  const _PdfPreview();

  static const _iconSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(
          Icons.picture_as_pdf_outlined,
          size: _iconSize,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: AppSpacing.sm),
        Text(UploadStrings.pdfPreviewNote, style: AppTypography.caption),
      ],
    );
  }
}

/// "보관할 곳" 입력창. 누르면 보관함 목록을 아래에서 띄웁니다.
class _BoxField extends StatefulWidget {
  const _BoxField({required this.state, required this.onSelected});

  final UploadState state;
  final ValueChanged<String> onSelected;

  @override
  State<_BoxField> createState() => _BoxFieldState();
}

class _BoxFieldState extends State<_BoxField> {
  late final _controller = TextEditingController(
    text: widget.state.selectedBox?.name,
  );

  @override
  void didUpdateWidget(_BoxField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.text = widget.state.selectedBox?.name ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showBoxes() async {
    final boxId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.dialogSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.medium),
        ),
      ),
      builder: (context) => _BoxSheet(
        boxes: widget.state.boxes,
        selectedBoxId: widget.state.selectedBoxId,
      ),
    );
    if (boxId != null) widget.onSelected(boxId);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: UploadStrings.boxLabel,
      controller: _controller,
      readOnly: true,
      onTap: _showBoxes,
      suffix: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BoxSheet extends StatelessWidget {
  const _BoxSheet({required this.boxes, required this.selectedBoxId});

  final List<DocumentBox> boxes;
  final String? selectedBoxId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final box in boxes)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                title: Text(box.name, style: AppTypography.listTitle),
                trailing: box.id == selectedBoxId
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, box.id),
              ),
          ],
        ),
      ),
    );
  }
}
