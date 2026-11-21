import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/auth/presentation/widgets/social_login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 회사 로고와 이름이 들어간 간편 로그인 버튼.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    required this.provider,
    required this.onPressed,
    super.key,
  });

  /// 어느 회사 로그인 버튼인지.
  final SocialLoginProvider provider;
  final VoidCallback onPressed;

  /// 버튼 높이.
  static const height = 57.0;
  static const _logoSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: provider.backgroundColor,
          foregroundColor: AppColors.socialLoginText,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
            side: BorderSide(color: provider.borderColor),
          ),
        ),
        // 버튼 높이가 정해져 있어, 글자를 크게 키우면 로고와 글자를 함께 줄여 버튼 안에 맞춥니다.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                provider.logoAsset,
                width: _logoSize,
                height: _logoSize,
              ),
              const SizedBox(width: AppSpacing.socialLogoGap),
              Text(provider.label),
            ],
          ),
        ),
      ),
    );
  }
}
