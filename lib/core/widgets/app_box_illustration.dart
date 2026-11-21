import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 뚜껑과 몸통으로 그린 보관함 상자. 몸통에 종류 아이콘과 날짜 표를 둡니다.
///
/// Figma `box/집 · 임대`에 해당합니다. 홈의 최근 보관함과 보관함 탭에서 함께 씁니다.
class AppBoxIllustration extends StatelessWidget {
  const AppBoxIllustration({
    required this.icon,
    this.lidColor = AppColors.boxLid,
    this.bodyColor = AppColors.boxBody,
    this.tagLabel,
    this.hasRoundedBody = false,
    super.key,
  });

  /// 상자 그림 높이. 상자 옆에 같은 높이의 칸을 둘 때도 씁니다.
  static const height = 118.0;

  /// 몸통 왼쪽 아래의 종류 아이콘.
  final IconData icon;

  /// 뚜껑과 손잡이 색.
  final Color lidColor;

  /// 몸통 색.
  final Color bodyColor;

  /// 몸통 오른쪽 아래 표의 글자. 예: "D-13". 비우면 표를 그리지 않습니다.
  final String? tagLabel;

  /// 몸통 아래 모서리를 둥글게 그릴지 여부. 보관함 탭의 상자는 둥급니다.
  final bool hasRoundedBody;

  static const _lidHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: AppSpacing.boxBodyInset,
            right: AppSpacing.boxBodyInset,
            top: AppSpacing.boxBodyTop,
            bottom: 0,
            child: _BoxBody(
              icon: icon,
              lidColor: lidColor,
              bodyColor: bodyColor,
              tagLabel: tagLabel,
              hasRoundedBody: hasRoundedBody,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: _lidHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: lidColor,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 상자 몸통. 손잡이, 종류 아이콘, 날짜 표를 담습니다.
class _BoxBody extends StatelessWidget {
  const _BoxBody({
    required this.icon,
    required this.lidColor,
    required this.bodyColor,
    required this.tagLabel,
    required this.hasRoundedBody,
  });

  final IconData icon;
  final Color lidColor;
  final Color bodyColor;
  final String? tagLabel;
  final bool hasRoundedBody;

  static const _handleWidth = 42.0;
  static const _handleHeight = 14.0;
  static const _iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final tagLabel = this.tagLabel;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bodyColor,
        borderRadius: hasRoundedBody
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.boxBody),
              )
            : null,
      ),
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
                color: lidColor,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(icon, size: _iconSize, color: AppColors.boxIcon),
                if (tagLabel != null)
                  // 글자를 크게 키워 몸통이 좁아지면 표를 줄여 몸통 안에 맞춥니다.
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _Tag(label: tagLabel),
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
class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

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
          label,
          style: AppTypography.tag.copyWith(color: AppColors.logo),
        ),
      ),
    );
  }
}
