import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/notification/application/notification_clock.dart';
import 'package:chagok_mobile/features/notification/application/notification_due.dart';
import 'package:chagok_mobile/features/notification/application/notification_filter.dart';
import 'package:chagok_mobile/features/notification/application/notification_filter_notifier.dart';
import 'package:chagok_mobile/features/notification/application/notification_list_notifier.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/presentation/notification_strings.dart';
import 'package:chagok_mobile/features/notification/presentation/widgets/notification_tabs.dart';
import 'package:chagok_mobile/features/notification/presentation/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// N01 · 받은 알림 목록. 홈의 종 버튼·최근 알림에서 들어옵니다.
class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notificationFilterProvider);

    return Scaffold(
      appBar: AppTopBar.plain(
        title: NotificationStrings.title,
        action: AppTopBarAction(
          icon: AppIcons.settings,
          semanticLabel: NotificationStrings.settings,
          // 설정 탭의 알림 설정으로 옮겨 갑니다. 뒤로 가면 설정 첫 화면입니다.
          onTap: () => context.go(AppRoute.notificationSettings),
        ),
      ),
      body: Column(
        children: [
          NotificationTabs(
            selected: filter,
            onSelect: (filter) =>
                ref.read(notificationFilterProvider.notifier).select(filter),
          ),
          Expanded(
            child: ref
                .watch(notificationListProvider)
                .when(
                  data: (notifications) => _NotificationList(
                    notifications: notifications,
                    filter: filter,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          NotificationStrings.loadFailed,
                          style: AppTypography.body,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton.secondary(
                          label: NotificationStrings.retry,
                          onPressed: () =>
                              ref.invalidate(notificationListProvider),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// 고른 탭의 알림과 "새 알림 n개 · 모두 읽음" 머리.
class _NotificationList extends ConsumerWidget {
  const _NotificationList({required this.notifications, required this.filter});

  final List<AppNotification> notifications;
  final NotificationFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(notificationClockProvider)();
    final shown = filter.apply(notifications);
    NotificationListNotifier notifier() =>
        ref.read(notificationListProvider.notifier);

    void open(AppNotification notification) {
      unawaited(notifier().markRead(notification.id));
      unawaited(context.push(AppRoute.notificationDetail(notification.id)));
    }

    Future<void> markAllRead() async {
      final isSaved = await notifier().markAllRead();
      if (isSaved || !context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(NotificationStrings.saveFailed)),
      );
    }

    return ListView(
      children: [
        _ListHeader(
          unreadCount: NotificationDue.unreadCount(notifications),
          onMarkAllRead: () => unawaited(markAllRead()),
        ),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Text(
              NotificationStrings.empty(filter),
              style: AppTypography.listSubtitle,
            ),
          ),
        for (final notification in shown) ...[
          NotificationTile(
            notification: notification,
            daysLeft: NotificationDue.daysLeft(notification, today),
            onTap: () => open(notification),
          ),
          const Divider(
            height: _dividerThickness,
            thickness: _dividerThickness,
            color: AppColors.noticeDivider,
          ),
        ],
      ],
    );
  }

  static const _dividerThickness = 1.0;
}

/// "새 알림 2개 · 모두 읽음" 한 줄. 읽지 않은 알림이 없으면 "모두 읽음"을 끕니다.
class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.unreadCount, required this.onMarkAllRead});

  final int unreadCount;
  final VoidCallback onMarkAllRead;

  static const _buttonMinHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.label.copyWith(color: AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              NotificationStrings.newCount(unreadCount),
              style: style,
            ),
          ),
          TextButton(
            onPressed: unreadCount == 0 ? null : onMarkAllRead,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: style,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, _buttonMinHeight),
            ),
            child: const Text(NotificationStrings.markAllRead),
          ),
        ],
      ),
    );
  }
}
