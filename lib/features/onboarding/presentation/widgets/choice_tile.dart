import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 여러 답 중 하나를 고르는 큰 선택지.
///
/// Figma `div.choice`에 해당합니다. 고르면 테두리가 주황으로 바뀌고
/// 오른쪽 ○ 표시가 ✓로 바뀝니다.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const height = 57.0;
  static const _padding = 17.0;
  static const _markSize = 18.0;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadius.medium);

    return Semantics(
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.fieldBorder,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: height),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _padding),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.option.copyWith(height: 18 / 15),
                    ),
                  ),
                  SizedBox.square(
                    dimension: _markSize,
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: _markSize,
                            color: AppColors.primary,
                          )
                        : const Center(child: _EmptyMark()),
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

/// 고르지 않은 선택지의 얇은 동그라미(○).
class _EmptyMark extends StatelessWidget {
  const _EmptyMark();

  static const _size = 14.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary),
      ),
    );
  }
}
