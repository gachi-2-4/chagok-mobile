import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/home/data/recent_alert.dart';
import 'package:chagok_mobile/features/home/presentation/home_strings.dart';
import 'package:chagok_mobile/features/home/presentation/widgets/home_card.dart';
import 'package:flutter/material.dart';

/// 최근 알림 몇 개를 담은 카드. 읽지 않은 알림은 주황 점과 굵은 글자로 보입니다.
class RecentAlertsCard extends StatelessWidget {
  const RecentAlertsCard({
    required this.alerts,
    required this.now,
    required this.onTap,
    super.key,
  });

  /// 보여 줄 알림. 최근 순서대로 넘깁니다.
  final List<RecentAlert> alerts;

  /// 알림 시각("방금", "어제" 등)을 셀 기준 시각.
  final DateTime now;

  /// 알림 하나를 눌렀을 때 그 알림을 받습니다.
  final ValueChanged<RecentAlert> onTap;

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.alertCardPaddingVertical,
      ),
      child: alerts.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                HomeStrings.noRecentAlerts,
                style: AppTypography.listSubtitle,
              ),
            )
          : Column(
              children: [
                for (final alert in alerts)
                  _AlertItem(alert: alert, now: now, onTap: () => onTap(alert)),
              ],
            ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  const _AlertItem({
    required this.alert,
    required this.now,
    required this.onTap,
  });

  final RecentAlert alert;
  final DateTime now;
  final VoidCallback onTap;

  static const _dotSize = 7.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: alert.isRead
                    ? AppColors.textPrimary.withValues(alpha: 0.1)
                    : AppColors.navActive,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.fieldLabel.copyWith(
                      fontWeight: alert.isRead
                          ? FontWeight.w400
                          : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.alertMetaGap),
                  Text(
                    HomeStrings.alertMeta(alert.boxName, alert.createdAt, now),
                    style: AppTypography.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
