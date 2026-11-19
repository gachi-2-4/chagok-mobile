import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 여러 개 중 하나를 고르는 목록 한 줄. 오른쪽에 라디오가 붙습니다.
///
/// Figma `Setting/SelectRow` 컴포넌트에 해당합니다. 예: 글자 크기 "보통/크게"
class AppSelectRow extends StatelessWidget {
  const AppSelectRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  static const height = 52.0;

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: isSelected,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: isSelected
                        ? AppTypography.option.copyWith(
                            fontWeight: FontWeight.w700,
                          )
                        : AppTypography.option,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SvgPicture.asset(
                  isSelected ? AppIcons.radioOn : AppIcons.radioOff,
                  width: 22,
                  height: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
