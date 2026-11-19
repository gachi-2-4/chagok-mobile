import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 체크박스와 문장으로 이루어진 목록 한 줄.
///
/// Figma `Setting/CheckRow` 컴포넌트에 해당합니다.
/// 예: "삭제 내용을 확인했어요", 약관 동의
class AppCheckRow extends StatelessWidget {
  const AppCheckRow({
    required this.label,
    required this.isChecked,
    required this.onChanged,
    super.key,
  });

  static const height = 52.0;

  final String label;
  final bool isChecked;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;

    return Semantics(
      checked: isChecked,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!isChecked),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  isChecked ? AppIcons.checkboxOn : AppIcons.checkboxOff,
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(label, style: AppTypography.option)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
