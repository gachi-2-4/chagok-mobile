import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
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

  /// 보여 줄 보관함.
  final RecentBox box;

  /// D-n과 "오늘 열람" 같은 표시를 셀 기준 시각.
  final DateTime now;
  final VoidCallback onTap;

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
            _BoxIllustration(
              category: box.category,
              dueDays: dueDays != null && dueDays >= 0 ? dueDays : null,
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

/// 뚜껑과 몸통으로 그린 상자. 몸통에 종류 아이콘과 D-n 표를 둡니다.
class _BoxIllustration extends StatelessWidget {
  const _BoxIllustration({required this.category, required this.dueDays});

  final BoxCategory category;

  /// 남은 날짜. 지난 일정이거나 없으면 null이고 표를 그리지 않습니다.
  final int? dueDays;

  /// Figma 상자 그림 크기.
  static const _height = 118.0;
  static const _lidHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Stack(
        children: [
          Positioned(
            left: AppSpacing.boxBodyInset,
            right: AppSpacing.boxBodyInset,
            top: AppSpacing.boxBodyTop,
            bottom: 0,
            child: _BoxBody(category: category, dueDays: dueDays),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: _lidHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.boxLid,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 상자 몸통. 손잡이, 종류 아이콘, D-n 표를 담습니다.
class _BoxBody extends StatelessWidget {
  const _BoxBody({required this.category, required this.dueDays});

  final BoxCategory category;
  final int? dueDays;

  static const _handleWidth = 42.0;
  static const _handleHeight = 14.0;
  static const _iconSize = 22.0;

  static IconData _iconFor(BoxCategory category) => switch (category) {
    BoxCategory.housing => Icons.home_outlined,
    BoxCategory.telecom => Icons.wifi_rounded,
    BoxCategory.car => Icons.directions_car_outlined,
    BoxCategory.other => Icons.folder_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final dueDays = this.dueDays;

    return ColoredBox(
      color: AppColors.boxBody,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.boxBodyPaddingStart,
          AppSpacing.boxBodyPaddingStart,
          AppSpacing.boxBodyPaddingEnd,
          AppSpacing.boxBodyPaddingEnd,
        ),
        child: Column(
          children: [
            Container(
              width: _handleWidth,
              height: _handleHeight,
              decoration: BoxDecoration(
                color: AppColors.boxLid,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  _iconFor(category),
                  size: _iconSize,
                  color: AppColors.boxIcon,
                ),
                if (dueDays != null)
                  // 글자를 크게 키워 몸통이 좁아지면 표를 줄여 몸통 안에 맞춥니다.
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _DueTag(days: dueDays),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.tagPaddingVertical,
        ),
        child: Text(
          HomeStrings.dDay(days),
          style: AppTypography.tag.copyWith(color: AppColors.logo),
        ),
      ),
    );
  }
}
