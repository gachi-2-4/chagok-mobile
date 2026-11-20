import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/constants/core_strings.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:flutter/material.dart';

/// 서류를 올리고 고치는 화면들의 공통 뼈대.
///
/// 브랜드 상단 바, 스크롤되는 본문, 아래 버튼 영역과 맨 아래 한 줄
/// 문구([tagline])로 이루어집니다. 예: 서류 올리기(U01~U04), 서류 상세(D01~D02)
class AppDocumentLayout extends StatelessWidget {
  const AppDocumentLayout({
    required this.body,
    required this.actions,
    super.key,
  });

  /// 맨 아래 한 줄 문구.
  static const tagline = CoreStrings.tagline;

  /// 본문에 위에서부터 쌓을 위젯.
  final List<Widget> body;

  /// 아래 버튼 영역에 쌓을 버튼. 버튼 사이는 [AppSpacing.buttonGap]만큼 띄웁니다.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: AppTopBar.logoText),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.pageTop,
                  AppSpacing.screenHorizontal,
                  AppSpacing.xl,
                ),
                children: body,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.block,
                AppSpacing.screenHorizontal,
                AppSpacing.actionsBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, action) in actions.indexed) ...[
                    if (index > 0) const SizedBox(height: AppSpacing.buttonGap),
                    action,
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    tagline,
                    textAlign: TextAlign.center,
                    style: AppTypography.label.copyWith(
                      color: AppColors.textFooter,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
