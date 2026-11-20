import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/presentation/notification_strings.dart';
import 'package:flutter/material.dart';

/// 알림 한 줄. 보낸 날짜·읽지 않음 점·D-n 표 아래에 제목을 보여 줍니다.
///
/// 읽은 알림은 제목을 흐리게 보여 줍니다.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    required this.onTap,
    this.daysLeft,
    super.key,
  });

  /// 보여 줄 알림.
  final AppNotification notification;

  /// 납부일·만기일까지 남은 날. 지났거나 날짜가 없으면 null이고 표를 숨깁니다.
  final int? daysLeft;

  /// 눌렀을 때.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.noticePaddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetaRow(
                sentAt: notification.sentAt,
                isRead: isRead,
                daysLeft: daysLeft,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                notification.title,
                style: isRead
                    ? AppTypography.choice.copyWith(
                        color: AppColors.textSecondary,
                      )
                    : AppTypography.choice,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "2026-11-18 · 오전 9:00 ●" 와 오른쪽 D-n 표 한 줄.
///
/// 날짜와 읽지 않음 점은 왼쪽에 붙이고, 글자를 키우면 날짜가 줄을 바꿔
/// 오른쪽 D-n 표 자리를 남깁니다.
class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.sentAt,
    required this.isRead,
    required this.daysLeft,
  });

  final DateTime sentAt;
  final bool isRead;
  final int? daysLeft;

  static const _dotSize = 6.0;

  @override
  Widget build(BuildContext context) {
    final daysLeft = this.daysLeft;

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  NotificationStrings.sentAt(sentAt),
                  style: AppTypography.noticeMeta,
                ),
              ),
              if (!isRead) ...[
                const SizedBox(width: AppSpacing.sm),
                Semantics(
                  label: NotificationStrings.unread,
                  child: Container(
                    width: _dotSize,
                    height: _dotSize,
                    decoration: const BoxDecoration(
                      color: AppColors.navActive,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (daysLeft != null) ...[
          const SizedBox(width: AppSpacing.sm),
          _DueTag(days: daysLeft),
        ],
      ],
    );
  }
}

/// 오른쪽 위의 "D-1" 표.
class _DueTag extends StatelessWidget {
  const _DueTag({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.peach,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.tagPaddingVertical,
        ),
        child: Text(NotificationStrings.dDay(days), style: AppTypography.tag),
      ),
    );
  }
}
