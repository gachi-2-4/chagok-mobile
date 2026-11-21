import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_resume_listener.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/home/application/home_clock.dart';
import 'package:chagok_mobile/features/home/application/home_notifier.dart';
import 'package:chagok_mobile/features/home/application/home_today_notifier.dart';
import 'package:chagok_mobile/features/home/data/home_summary.dart';
import 'package:chagok_mobile/features/home/presentation/home_strings.dart';
import 'package:chagok_mobile/features/home/presentation/widgets/home_section.dart';
import 'package:chagok_mobile/features/home/presentation/widgets/mini_calendar_card.dart';
import 'package:chagok_mobile/features/home/presentation/widgets/recent_alerts_card.dart';
import 'package:chagok_mobile/features/home/presentation/widgets/recent_box_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// M00 · 앱을 열면 처음 보이는 홈 화면.
///
/// 이번 주 일정, 최근 연 보관함, 최근 알림을 모아 보여 줍니다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(homeProvider);
    final hasUnreadAlert = summary.when(
      data: (summary) => summary.hasUnreadAlert,
      loading: () => false,
      error: (error, stackTrace) => false,
    );

    void openNotifications() => unawaited(context.push(AppRoute.notifications));

    // 앱이 멈춰 있는 동안 자정이 지났을 수 있어 돌아오면 날짜를 다시 확인합니다.
    return AppResumeListener(
      onResume: () => ref.read(homeTodayProvider.notifier).refresh(),
      child: Scaffold(
        appBar: AppTopBar.logo(
          action: AppTopBarAction(
            icon: AppIcons.bell,
            // 점은 화면 읽기 프로그램이 읽지 못하므로 이름에 상태를 담습니다.
            semanticLabel: hasUnreadAlert
                ? HomeStrings.notificationsUnread
                : HomeStrings.notifications,
            onTap: openNotifications,
            hasBadge: hasUnreadAlert,
          ),
        ),
        body: summary.when(
          data: (summary) => RefreshIndicator(
            onRefresh: () => ref.read(homeProvider.notifier).refresh(),
            child: _HomeContent(
              summary: summary,
              now: ref.watch(homeClockProvider)(),
              onAlertTap: openNotifications,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(HomeStrings.loadFailed, style: AppTypography.body),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton.secondary(
                    label: HomeStrings.retry,
                    onPressed: () => ref.invalidate(homeProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.summary,
    required this.now,
    required this.onAlertTap,
  });

  final HomeSummary summary;
  final DateTime now;
  final VoidCallback onAlertTap;

  @override
  Widget build(BuildContext context) {
    final boxes = summary.recentBoxes.take(2).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.pageTopCompact,
        AppSpacing.screenHorizontal,
        AppSpacing.xl,
      ),
      children: [
        HomeSection(
          title: HomeStrings.miniCalendar,
          linkLabel: HomeStrings.monthLink(now),
          onLinkTap: () => context.go(AppRoute.calendar),
          child: MiniCalendarCard(today: now, schedules: summary.schedules),
        ),
        const SizedBox(height: AppSpacing.block),
        HomeSection(
          title: HomeStrings.recentBoxes,
          linkLabel: HomeStrings.viewAll,
          onLinkTap: () => context.go(AppRoute.archive),
          child: boxes.isEmpty
              ? const Text(
                  HomeStrings.noRecentBoxes,
                  style: AppTypography.listSubtitle,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (index, box) in boxes.indexed) ...[
                      if (index > 0) const SizedBox(width: AppSpacing.cardGap),
                      Expanded(
                        child: RecentBoxCard(
                          box: box,
                          now: now,
                          onTap: () => context.go(AppRoute.archiveBox(box.id)),
                        ),
                      ),
                    ],
                    if (boxes.length == 1) ...[
                      const SizedBox(width: AppSpacing.cardGap),
                      const Spacer(),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.block),
        HomeSection(
          title: HomeStrings.recentAlerts,
          linkLabel: HomeStrings.viewAll,
          onLinkTap: onAlertTap,
          child: RecentAlertsCard(
            alerts: summary.recentAlerts.take(3).toList(),
            now: now,
            onTap: (_) => onAlertTap(),
          ),
        ),
      ],
    );
  }
}
