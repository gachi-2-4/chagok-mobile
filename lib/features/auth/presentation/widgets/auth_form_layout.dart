import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// 회원가입·로그인 화면의 공통 뼈대.
///
/// 위에는 스크롤되는 본문, 아래에는 화면 끝에 붙는 버튼 영역을 둡니다.
/// 키보드가 올라오면 버튼 영역도 함께 올라갑니다.
class AuthFormLayout extends StatelessWidget {
  const AuthFormLayout({
    required this.body,
    required this.actions,
    this.appBar,
    super.key,
  });

  /// 화면 위 상단 바. 비우면 상단 바 없이 위쪽 안전 영역만 띄웁니다.
  final PreferredSizeWidget? appBar;

  /// 본문에 위에서부터 쌓을 위젯.
  final List<Widget> body;

  /// 화면 아래 버튼 영역에 쌓을 위젯.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        top: appBar == null,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenHorizontal,
                  AppSpacing.md,
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
                children: actions,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
