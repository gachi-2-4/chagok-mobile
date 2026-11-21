import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_resume_listener.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/archive/application/archive_box_item.dart';
import 'package:chagok_mobile/features/archive/application/archive_today_notifier.dart';
import 'package:chagok_mobile/features/archive/application/box_list_notifier.dart';
import 'package:chagok_mobile/features/archive/application/unread_notification_provider.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/archive_box_card.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/archive_search_button.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/new_box_card.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/new_box_sheet.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/upload_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 04 · 보관함 탭 첫 화면.
///
/// 내 보관함을 상자 그림으로 두 줄씩 늘어놓고, 끝에 새 박스 칸을 둡니다.
class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnreadAlert = ref.watch(hasUnreadNotificationProvider);

    // 앱이 멈춰 있는 동안 자정이 지났을 수 있어 돌아오면 D-n 기준 날짜를 다시 확인합니다.
    // 보관함 탭은 다른 탭에 있어도 살아 있으므로 박스 상세·검색의 D-n도 함께 맞춰집니다.
    return AppResumeListener(
      onResume: () => ref.read(archiveTodayProvider.notifier).refresh(),
      child: Scaffold(
        appBar: AppTopBar.logo(
          action: AppTopBarAction(
            icon: AppIcons.bell,
            // 점은 화면 읽기 프로그램이 읽지 못하므로 이름에 상태를 담습니다.
            semanticLabel: hasUnreadAlert
                ? ArchiveStrings.notificationsUnread
                : ArchiveStrings.notifications,
            onTap: () => unawaited(context.push(AppRoute.notifications)),
            hasBadge: hasUnreadAlert,
          ),
        ),
        floatingActionButton: const UploadButton(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.pageTop,
            AppSpacing.screenHorizontal,
            AppSpacing.floatingButtonClearance,
          ),
          children: [
            const Text(ArchiveStrings.title, style: AppTypography.pageTitle),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: ArchiveSearchButton(
                onTap: () => unawaited(context.push(AppRoute.archiveSearch)),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGapLarge),
            const _BoxListSection(),
          ],
        ),
      ),
    );
  }
}

/// 보관함 목록. 불러오는 중·실패·목록 상태를 모두 보여 줍니다.
class _BoxListSection extends ConsumerWidget {
  const _BoxListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(boxListProvider)
        .when(
          data: (items) => _BoxGrid(items: items),
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Column(
            children: [
              const Text(ArchiveStrings.loadFailed, style: AppTypography.body),
              const SizedBox(height: AppSpacing.lg),
              AppButton.secondary(
                label: ArchiveStrings.retry,
                onPressed: () => ref.invalidate(boxListProvider),
              ),
            ],
          ),
        );
  }
}

/// 보관함을 두 개씩 한 줄에 늘어놓고, 마지막에 새 박스 칸을 둡니다.
class _BoxGrid extends StatelessWidget {
  const _BoxGrid({required this.items});

  final List<ArchiveBoxItem> items;

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[
      for (final item in items)
        ArchiveBoxCard(
          item: item,
          onTap: () =>
              unawaited(context.push(AppRoute.archiveBox(item.box.id))),
        ),
      NewBoxCard(onTap: () => unawaited(showNewBoxSheet(context))),
    ];

    return Column(
      children: [
        for (var start = 0; start < cells.length; start += 2) ...[
          if (start > 0) const SizedBox(height: AppSpacing.gridRowGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cells[start]),
              const SizedBox(width: AppSpacing.gridColumnGap),
              Expanded(
                child: start + 1 < cells.length
                    ? cells[start + 1]
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
