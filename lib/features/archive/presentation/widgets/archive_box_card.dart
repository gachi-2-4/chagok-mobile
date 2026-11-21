import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_box_illustration.dart';
import 'package:chagok_mobile/features/archive/application/archive_box_item.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:chagok_mobile/features/archive/presentation/widgets/box_style.dart';
import 'package:flutter/material.dart';

/// 보관함 목록(04)의 상자 하나. 상자 그림 아래에 이름과 서류 수를 둡니다.
class ArchiveBoxCard extends StatelessWidget {
  const ArchiveBoxCard({required this.item, required this.onTap, super.key});

  final ArchiveBoxItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final box = item.box;
    final daysLeft = item.daysLeft;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBoxIllustration(
              icon: BoxStyle.icon(box.icon),
              lidColor: BoxStyle.lidColor(box.color),
              bodyColor: BoxStyle.bodyColor(box.color),
              tagLabel: daysLeft == null ? null : ArchiveStrings.dDay(daysLeft),
              hasRoundedBody: true,
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
              ArchiveStrings.documentCount(box.documentCount),
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
