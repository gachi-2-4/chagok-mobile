import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_box_illustration.dart';
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

  /// 보여 줄 보관함.
  final RecentBox box;

  /// D-n과 "오늘 열람" 같은 표시를 셀 기준 시각.
  final DateTime now;
  final VoidCallback onTap;

  static IconData _iconFor(BoxCategory category) => switch (category) {
    BoxCategory.housing => Icons.home_outlined,
    BoxCategory.telecom => Icons.wifi_rounded,
    BoxCategory.car => Icons.directions_car_outlined,
    BoxCategory.other => Icons.folder_outlined,
  };

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
            AppBoxIllustration(
              icon: _iconFor(box.category),
              tagLabel: dueDays != null && dueDays >= 0
                  ? HomeStrings.dDay(dueDays)
                  : null,
            ),
            const SizedBox(height: AppSpacing.boxLabelGap),
            Text(
              box.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.boxName,
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
}
