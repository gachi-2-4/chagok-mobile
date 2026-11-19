import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

enum _AppButtonVariant { primary, secondary }

/// 화면 하단 등에 쓰는 가로로 꽉 찬 알약 모양 버튼.
///
/// - [AppButton.primary]: 주황 배경. 화면의 주된 동작. 예: "다음", "로그인"
/// - [AppButton.secondary]: 밝은 배경 + 테두리. 보조 동작. 예: "나중에 할게요"
///
/// [onPressed]가 null이면 비활성화됩니다.
class AppButton extends StatelessWidget {
  const AppButton.primary({
    required this.label,
    required this.onPressed,
    super.key,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    super.key,
  }) : _variant = _AppButtonVariant.secondary;

  static const height = 51.0;

  final String label;
  final VoidCallback? onPressed;
  final _AppButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
    );
    const minimumSize = Size.fromHeight(height);
    final child = Text(label, style: AppTypography.button);

    return switch (_variant) {
      _AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.onPrimary,
          minimumSize: minimumSize,
          shape: shape,
        ),
        child: child,
      ),
      _AppButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.secondaryButtonText,
          disabledForegroundColor: AppColors.secondaryButtonText.withValues(
            alpha: 0.4,
          ),
          side: const BorderSide(color: AppColors.secondaryButtonBorder),
          minimumSize: minimumSize,
          shape: shape,
        ),
        child: child,
      ),
    };
  }
}
