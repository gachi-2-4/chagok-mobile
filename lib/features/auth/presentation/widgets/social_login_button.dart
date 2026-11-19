import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 간편 로그인 제공자.
///
/// 버튼 색은 각 회사 로그인 버튼 가이드의 색이라 디자인 토큰에 두지 않습니다.
enum SocialLoginProvider {
  kakao(
    label: AuthStrings.kakaoLogin,
    logoAsset: 'assets/icons/logo_kakao.svg',
    backgroundColor: Color(0xFFFEE500),
    borderColor: Color(0xFFFEE500),
  ),
  google(
    label: AuthStrings.googleLogin,
    logoAsset: 'assets/icons/logo_google.svg',
    backgroundColor: AppColors.surface,
    borderColor: AppColors.background,
  );

  const SocialLoginProvider({
    required this.label,
    required this.logoAsset,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final String logoAsset;
  final Color backgroundColor;
  final Color borderColor;
}

/// 회사 로고와 이름이 들어간 간편 로그인 버튼.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    required this.provider,
    required this.onPressed,
    super.key,
  });

  final SocialLoginProvider provider;
  final VoidCallback onPressed;

  static const height = 57.0;
  static const _logoSize = 24.0;

  /// 간편 로그인 버튼 글자색. 두 버튼 모두 같은 진한 색을 씁니다.
  static const _foregroundColor = Color(0xFF302B19);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: provider.backgroundColor,
          foregroundColor: _foregroundColor,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
            side: BorderSide(color: provider.borderColor),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              provider.logoAsset,
              width: _logoSize,
              height: _logoSize,
            ),
            const SizedBox(width: AppSpacing.sm - 2),
            Text(provider.label),
          ],
        ),
      ),
    );
  }
}
