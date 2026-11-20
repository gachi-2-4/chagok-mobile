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

  /// 한 줄일 때의 높이. 글자가 길거나 커지면 내용에 맞게 늘어납니다.
  static const minHeight = 52.0;

  final String label;
  final bool isChecked;
  final ValueChanged<bool>? onChanged;

  static const _iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;

    return Semantics(
      checked: isChecked,
      child: InkWell(
        onTap: onChanged == null ? null : () => onChanged(!isChecked),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  isChecked ? AppIcons.checkboxOn : AppIcons.checkboxOff,
                  width: _iconSize,
                  height: _iconSize,
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
