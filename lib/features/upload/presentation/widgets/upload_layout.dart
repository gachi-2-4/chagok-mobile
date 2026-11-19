import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:flutter/material.dart';

/// 서류 올리기 화면들의 공통 뼈대.
///
/// 브랜드 상단 바, 스크롤되는 본문, 아래 버튼 영역과 맨 아래 한 줄
/// 문구("차곡차곡, 쉬워지는 서류 생활")로 이루어집니다.
class UploadLayout extends StatelessWidget {
  const UploadLayout({required this.body, required this.actions, super.key});

  /// 본문에 위에서부터 쌓을 위젯.
  final List<Widget> body;

  /// 아래 버튼 영역에 쌓을 버튼. 버튼 사이는 [AppSpacing.buttonGap]만큼 띄웁니다.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: UploadStrings.brand),
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
                    UploadStrings.tagline,
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
