import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 체크 표시(✓/○)와 문장으로 이루어진, 눌러서 켜고 끄는 한 줄.
///
/// Figma 로그인 화면의 "✓ 자동 로그인", 약관 동의 카드의 각 줄에 해당합니다.
/// 체크박스 테두리 없이 표시만 바뀝니다.
class CheckLabel extends StatelessWidget {
  const CheckLabel({
    required this.label,
    required this.isChecked,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isChecked;
  final VoidCallback onTap;

  static const _iconSize = 18.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: isChecked,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: kMinInteractiveDimension,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isChecked ? Icons.check_rounded : Icons.circle_outlined,
                size: _iconSize,
                color: isChecked ? AppColors.textPrimary : AppColors.chevron,
              ),
              const SizedBox(width: AppSpacing.md),
              Flexible(child: Text(label, style: AppTypography.body)),
            ],
          ),
        ),
      ),
    );
  }
}
