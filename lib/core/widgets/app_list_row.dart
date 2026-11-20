import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 제목 · 현재 값 · 화살표로 이루어진 목록 한 줄.
///
/// Figma `Setting/Row` 컴포넌트에 해당합니다. 예: "글자 크기  보통 ›"
class AppListRow extends StatelessWidget {
  const AppListRow({
    required this.title,
    this.value,
    this.onTap,
    this.showChevron = true,
    this.isDestructive = false,
    super.key,
  });

  /// 한 줄일 때의 높이. 글자가 길거나 커지면 내용에 맞게 늘어납니다.
  static const minHeight = 50.0;

  /// 제목과 값이 나눠 가질 너비 비율. 값보다 제목에 더 많이 줍니다.
  static const _titleFlex = 3;
  static const _valueFlex = 2;
  static const _chevronSize = 20.0;

  final String title;

  /// 오른쪽에 흐리게 보이는 현재 값. 예: "보통", "v1.0.0"
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;

  /// "회원 탈퇴"처럼 되돌리기 어려운 동작이면 true. 제목이 빨갛게 보입니다.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final value = this.value;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                flex: _titleFlex,
                child: Text(
                  title,
                  style: isDestructive
                      ? AppTypography.listTitle.copyWith(
                          color: AppColors.danger,
                        )
                      : AppTypography.listTitle,
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: AppSpacing.sm),
                // 값이 길어도 가로로 넘치지 않고 줄을 바꾸도록 너비를 제한합니다.
                // Align으로 받은 칸을 꽉 채워야 값이 행의 오른쪽 끝에 붙습니다.
                Flexible(
                  flex: _valueFlex,
                  child: Align(
                    alignment: Alignment.centerRight,
                    // 높이 제한이 있는 부모에서도 세로로 늘어나지 않고 글자 높이에 맞춥니다.
                    heightFactor: 1,
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: AppTypography.listValue,
                    ),
                  ),
                ),
              ],
              if (showChevron) ...[
                const SizedBox(width: AppSpacing.sm),
                SvgPicture.asset(
                  AppIcons.chevronRight,
                  width: _chevronSize,
                  height: _chevronSize,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
