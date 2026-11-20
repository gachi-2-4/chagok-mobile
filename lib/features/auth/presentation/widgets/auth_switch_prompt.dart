import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 회원가입과 로그인 화면을 오가는 안내 한 줄.
///
/// 예: "이미 계정이 있나요?  로그인"
///
/// 글자를 키우거나 화면이 좁으면 버튼을 다음 줄로 넘겨, 넘치지 않고 누를 수 있게 합니다.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    required this.message,
    required this.actionLabel,
    required this.onTap,
    super.key,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xs,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppTypography.caption,
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.secondaryButtonText,
            textStyle: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w700,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            minimumSize: const Size(0, kMinInteractiveDimension),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
