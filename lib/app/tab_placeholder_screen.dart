import 'package:chagok_mobile/app/app_strings.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';

/// 아직 만들지 않은 탭 자리에 두는 임시 화면.
///
/// 각 탭 기능을 만들면 `router.dart`에서 실제 화면으로 바꿉니다.
class TabPlaceholderScreen extends StatelessWidget {
  const TabPlaceholderScreen({required this.title, super.key});

  /// 상단 바에 보일 탭 이름. 예: "보관함"
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: title, showBackButton: false),
      body: const Center(
        child: Text(
          AppStrings.comingSoon,
          style: AppTypography.pageDescription,
        ),
      ),
    );
  }
}
