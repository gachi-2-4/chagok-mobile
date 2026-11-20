import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/calendar/data/deadline.dart';
import 'package:chagok_mobile/features/calendar/presentation/calendar_strings.dart';
import 'package:chagok_mobile/features/calendar/presentation/widgets/due_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 기한 한 줄. 왼쪽은 D-n 표, 가운데는 이름과 날짜, 오른쪽은 캘린더 등록 버튼.
class DeadlineTile extends StatelessWidget {
  const DeadlineTile({
    required this.deadline,
    required this.daysLeft,
    required this.onToggleRegistered,
    super.key,
  });

  /// 보여 줄 기한.
  final Deadline deadline;

  /// 오늘부터 기한까지 남은 날 수.
  final int daysLeft;

  /// 등록 버튼을 눌렀을 때.
  final VoidCallback onToggleRegistered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          DueTag(days: daysLeft),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deadline.title, style: AppTypography.deadlineTitle),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  CalendarStrings.deadlineMeta(deadline.dueDate, deadline.tags),
                  style: AppTypography.listSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _RegisterButton(
            title: deadline.title,
            isRegistered: deadline.isRegistered,
            onTap: onToggleRegistered,
          ),
        ],
      ),
    );
  }
}

/// 기기 캘린더 등록 버튼. 등록하면 색이 꽉 찬 원으로 바뀝니다.
class _RegisterButton extends StatelessWidget {
  const _RegisterButton({
    required this.title,
    required this.isRegistered,
    required this.onTap,
  });

  final String title;
  final bool isRegistered;
  final VoidCallback onTap;

  static const _size = 40.0;
  static const _iconSize = 17.0;
  static const _borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: isRegistered,
      label: CalendarStrings.registerSemantics(
        title,
        isRegistered: isRegistered,
      ),
      excludeSemantics: true,
      child: Material(
        color: isRegistered ? AppColors.primary : AppColors.transparent,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.primary, width: _borderWidth),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: _size,
            child: Center(
              child: SvgPicture.asset(
                isRegistered ? AppIcons.calendarAdded : AppIcons.calendarAdd,
                width: _iconSize,
                height: _iconSize,
                colorFilter: ColorFilter.mode(
                  isRegistered ? AppColors.calendarSurface : AppColors.logo,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
