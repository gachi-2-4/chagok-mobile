import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/home/application/schedule_calendar.dart';
import 'package:chagok_mobile/features/home/data/box_category.dart';
import 'package:chagok_mobile/features/home/data/recent_box.dart';
import 'package:chagok_mobile/features/home/presentation/home_strings.dart';
import 'package:flutter/material.dart';

/// 상자 그림과 이름으로 보여 주는 최근 보관함 하나.
///
/// Figma `box/집 · 임대`에 해당합니다. 뚜껑 아래 상자 몸통에 종류 아이콘과
/// 가장 가까운 납부·만기일(D-n)을 표시합니다.
class RecentBoxCard extends StatelessWidget {
  const RecentBoxCard({
    required this.box,
    required this.now,
    required this.onTap,
    super.key,
  });

  final RecentBox box;
  final DateTime now;
  final VoidCallback onTap;

  /// Figma 상자 그림 크기.
  static const _illustrationHeight = 118.0;
  static const _lidHeight = 28.0;
  static const _bodyInset = 9.0;
  static const _bodyTop = 22.0;
  static const _handleWidth = 42.0;
  static const _handleHeight = 14.0;
  static const _iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final dueDate = box.nextDueDate;
    final dueDays = dueDate == null
        ? null
        : ScheduleCalendar.daysUntil(now, dueDate);

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _illustrationHeight,
              child: Stack(
                children: [
                  Positioned(
                    left: _bodyInset,
                    right: _bodyInset,
                    top: _bodyTop,
                    bottom: 0,
                    child: ColoredBox(
                      color: AppColors.boxBody,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
                        child: Column(
                          children: [
                            Container(
                              width: _handleWidth,
                              height: _handleHeight,
                              decoration: BoxDecoration(
                                color: AppColors.boxLid,
                                borderRadius: BorderRadius.circular(
                                  _handleHeight,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(
                                  _iconFor(box.category),
                                  size: _iconSize,
                                  color: AppColors.boxIcon,
                                ),
                                const Spacer(),
                                if (dueDays != null && dueDays >= 0)
                                  _DueTag(days: dueDays),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: _lidHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.boxLid,
                        borderRadius: BorderRadius.circular(_lidHeight / 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              box.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 16,
                height: 19.2 / 16,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              HomeStrings.boxDetail(box.documentCount, box.lastOpenedAt, now),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.listSubtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(BoxCategory category) => switch (category) {
    BoxCategory.housing => Icons.home_outlined,
    BoxCategory.telecom => Icons.wifi_rounded,
    BoxCategory.car => Icons.directions_car_outlined,
    BoxCategory.other => Icons.folder_outlined,
  };
}

/// 상자 몸통 오른쪽 아래의 "D-13" 표.
class _DueTag extends StatelessWidget {
  const _DueTag({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.boxTag,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          HomeStrings.dDay(days),
          style: AppTypography.label.copyWith(
            fontSize: 11,
            height: 13.2 / 11,
            fontWeight: FontWeight.w700,
            color: AppColors.logo,
          ),
        ),
      ),
    );
  }
}
