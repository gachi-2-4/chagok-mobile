import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/extensions/scroll_end_inset.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_circle_back_button.dart';
import 'package:chagok_mobile/core/widgets/app_option_sheet.dart';
import 'package:chagok_mobile/features/archive/application/document_overview_item.dart';
import 'package:chagok_mobile/features/archive/application/document_overview_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/box_document_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/summary_section.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/document_tab.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/box_style.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/document_info_card.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/document_summary_card.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/document_tab_bar.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/original_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 07~09 · 서류 하나를 원본 또는 AI 정리본으로 보여 주는 화면.
///
/// 아래 카드에 중요도·비용·D-day를 두고, 기한이 있으면 납부일 알림(D02)으로
/// 이어집니다. 오른쪽 위 더보기에서 내용 수정(D01)으로 갈 수 있습니다.
class DocumentOverviewScreen extends ConsumerStatefulWidget {
  const DocumentOverviewScreen({
    required this.documentId,
    this.initialTab = DocumentTab.original,
    super.key,
  });

  /// 보여 줄 서류 id.
  final String documentId;

  /// 처음 열 탭. 서류 카드의 초록 버튼으로 열면 AI 정리본입니다.
  final DocumentTab initialTab;

  @override
  ConsumerState<DocumentOverviewScreen> createState() =>
      _DocumentOverviewScreenState();
}

class _DocumentOverviewScreenState
    extends ConsumerState<DocumentOverviewScreen> {
  // 고른 탭은 이 화면 안에서만 쓰고 다른 화면과 나누지 않으며, 화면을 벗어나면
  // 처음 탭으로 다시 열어야 하므로 Notifier 대신 State에 둡니다.
  late DocumentTab _tab = widget.initialTab;

  void _selectTab(DocumentTab tab) => setState(() => _tab = tab);

  Future<void> _openEdit() async {
    // 수정 화면에서 "원본 확인하기"를 누르면 true를 돌려주고 닫힙니다.
    final showOriginal = await context.push<bool>(
      AppRoute.documentEdit(widget.documentId),
    );
    if (showOriginal == true && mounted) _selectTab(DocumentTab.original);
  }

  Future<void> _openReminder() =>
      context.push(AppRoute.paymentReminder(widget.documentId));

  Future<void> _openMore() async {
    final action = await showAppOptionSheet(
      context,
      options: _DocumentAction.values,
      labelOf: (action) => switch (action) {
        _DocumentAction.edit => ArchiveStrings.editContent,
        _DocumentAction.reminder => ArchiveStrings.paymentReminder,
      },
    );
    if (!mounted) return;
    switch (action) {
      case _DocumentAction.edit:
        await _openEdit();
      case _DocumentAction.reminder:
        await _openReminder();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = documentOverviewProvider(widget.documentId);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ref
            .watch(provider)
            .when(
              data: (item) => _OverviewContent(
                item: item,
                tab: _tab,
                onSelectTab: _selectTab,
                onMore: () => unawaited(_openMore()),
                onDeadlineTap: () => unawaited(_openReminder()),
              ),
              loading: () => const _OverviewFrame(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => _OverviewFrame(
                child: _OverviewError(
                  isNotFound: error is BoxDocumentNotFoundException,
                  onRetry: () => ref.invalidate(provider),
                ),
              ),
            ),
      ),
    );
  }
}

/// 더보기에서 고를 수 있는 동작.
enum _DocumentAction { edit, reminder }

/// 불러온 서류의 머리·탭·원본 또는 AI 정리본·정보 카드.
class _OverviewContent extends StatelessWidget {
  const _OverviewContent({
    required this.item,
    required this.tab,
    required this.onSelectTab,
    required this.onMore,
    required this.onDeadlineTap,
  });

  final DocumentOverviewItem item;
  final DocumentTab tab;
  final ValueChanged<DocumentTab> onSelectTab;
  final VoidCallback onMore;
  final VoidCallback onDeadlineTap;

  @override
  Widget build(BuildContext context) {
    final overview = item.overview;
    final document = overview.document;

    return ListView(
      // 바깥 SafeArea가 아래를 비워 두지 않으므로, 끝 여백에 홈 인디케이터·Android
      // 내비게이션 바 높이를 더해 맨 아래 버튼이 가리지 않게 합니다.
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.pageTop,
        AppSpacing.screenHorizontal,
        context.scrollEndInset(gap: AppSpacing.actionsBottom),
      ),
      children: [
        _OverviewHeader(box: overview.box, onMore: onMore),
        const SizedBox(height: AppSpacing.block),
        DocumentTabBar(selected: tab, onSelect: onSelectTab),
        const SizedBox(height: AppSpacing.md),
        switch (tab) {
          DocumentTab.original => OriginalViewer(
            title: document.title,
            pageCount: document.pageCount,
            facts: [
              for (final section in overview.summary.sections)
                if (section is SummaryTable) ...section.rows,
            ],
            onOpenSummary: () => onSelectTab(DocumentTab.summary),
          ),
          DocumentTab.summary => DocumentSummaryCard(
            title: document.title,
            summary: overview.summary,
            onViewOriginal: () => onSelectTab(DocumentTab.original),
          ),
        },
        const SizedBox(height: AppSpacing.sectionGapLarge),
        DocumentInfoCard(item: item, onDeadlineTap: onDeadlineTap),
      ],
    );
  }
}

/// 불러오는 중이거나 실패했을 때도 뒤로 갈 수 있도록 뒤로 가기 버튼을 둔 틀.
class _OverviewFrame extends StatelessWidget {
  const _OverviewFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.pageTop,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppCircleBackButton(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// 서류를 불러오지 못했을 때의 안내. 없는 서류면 다시 시도를 두지 않습니다.
class _OverviewError extends StatelessWidget {
  const _OverviewError({required this.isNotFound, required this.onRetry});

  final bool isNotFound;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isNotFound
                ? ArchiveStrings.documentNotFound
                : ArchiveStrings.documentLoadFailed,
            style: AppTypography.body,
          ),
          if (!isNotFound) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton.secondary(
              label: ArchiveStrings.retry,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}

/// 뒤로 가기, 가운데 보관함 이름, 오른쪽 더보기.
class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.box, required this.onMore});

  final ArchiveBox box;
  final VoidCallback onMore;

  static const _boxIconSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppCircleBackButton(),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                BoxStyle.icon(box.icon),
                size: _boxIconSize,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  box.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.listSubtitle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox.square(
          dimension: AppCircleBackButton.size,
          child: IconButton(
            onPressed: onMore,
            tooltip: ArchiveStrings.moreActions,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.more_horiz_rounded,
              size: AppIcons.mediumSize,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
