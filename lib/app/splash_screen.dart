import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/constants/core_strings.dart';
import 'package:flutter/material.dart';

/// 01 · 앱을 열 때 저장한 로그인 정보를 확인하는 동안 보이는 시작 화면.
///
/// 확인이 끝나면 라우터가 로그인 화면이나 홈으로 보냅니다.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(CoreStrings.appName, style: AppTypography.splashLogo),
            SizedBox(height: AppSpacing.sectionGapLarge),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
