import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 앱 테마.
///
/// 색상·글자 스타일 토큰은 `core/constants`에 있고, 여기서는 그 값을
/// Material 테마에 연결합니다. 디자인에 다크 모드가 없어 라이트 테마만 둡니다.
abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.toggleOn,
      onSecondary: AppColors.toggleKnob,
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainer: AppColors.surface,
      outline: AppColors.fieldBorder,
      outlineVariant: AppColors.divider,
      error: AppColors.danger,
    );

    return ThemeData(
      // 토큰을 쓰지 않는 Material 기본 위젯의 글자도 같은 글꼴로 그립니다.
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      textTheme: const TextTheme(
        headlineSmall: AppTypography.pageTitle,
        titleLarge: AppTypography.topBarTitle,
        titleMedium: AppTypography.cardTitle,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.pageDescription,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
        labelSmall: AppTypography.label,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.topBarTitle,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.dialogSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }
}
