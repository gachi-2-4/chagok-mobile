import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/notification/application/notification_filter.dart';
import 'package:chagok_mobile/features/notification/presentation/notification_strings.dart';
import 'package:flutter/material.dart';

/// 전체 / 읽지 않음 / 완료 탭. 고른 탭은 바탕을 비우고 굵게 보여 줍니다.
class NotificationTabs extends StatelessWidget {
  const NotificationTabs({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// 고른 탭.
  final NotificationFilter selected;

  /// 탭을 눌렀을 때.
  final ValueChanged<NotificationFilter> onSelect;

  static const _height = 48.0;
  static const _dividerThickness = 1.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (final filter in NotificationFilter.values)
              Expanded(
                child: _Tab(
                  label: NotificationStrings.filter(filter),
                  isSelected: filter == selected,
                  onTap: () => onSelect(filter),
                ),
              ),
          ],
        ),
        const Divider(
          height: _dividerThickness,
          thickness: _dividerThickness,
          color: AppColors.noticeDivider,
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? AppColors.transparent : AppColors.tabInactiveFill,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: NotificationTabs._height,
            child: Center(
              child: Text(
                label,
                style: isSelected
                    ? AppTypography.choice.copyWith(fontWeight: FontWeight.w700)
                    : AppTypography.choice.copyWith(
                        color: AppColors.textDisabled,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
