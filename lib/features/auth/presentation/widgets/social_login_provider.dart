import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/features/auth/presentation/auth_strings.dart';
import 'package:flutter/painting.dart';

/// 간편 로그인 제공자와 그 회사 로그인 버튼의 모양.
enum SocialLoginProvider {
  /// 카카오.
  kakao(
    label: AuthStrings.kakaoLogin,
    logoAsset: AppIcons.logoKakao,
    backgroundColor: AppColors.kakao,
    borderColor: AppColors.kakao,
  ),

  /// 구글.
  google(
    label: AuthStrings.googleLogin,
    logoAsset: AppIcons.logoGoogle,
    backgroundColor: AppColors.surface,
    borderColor: AppColors.background,
  );

  const SocialLoginProvider({
    required this.label,
    required this.logoAsset,
    required this.backgroundColor,
    required this.borderColor,
  });

  /// 버튼 글자. 예: "kakao 로그인"
  final String label;

  /// [AppIcons]의 회사 로고 SVG 경로.
  final String logoAsset;

  /// 버튼 배경색.
  final Color backgroundColor;

  /// 버튼 테두리색.
  final Color borderColor;
}
