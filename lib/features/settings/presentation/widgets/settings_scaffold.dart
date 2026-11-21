import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:flutter/material.dart';

/// 설정 화면들의 공통 뼈대.
///
/// 목록은 화면 끝까지 꽉 차고(좌우 여백 없음), 아래에 버튼 영역을 둘 수 있습니다.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    required this.appBar,
    required this.body,
    this.actions = const [],
    super.key,
  });

  /// 화면 위 상단 바.
  final PreferredSizeWidget appBar;

  /// 위에서부터 쌓을 목록 내용.
  final List<Widget> body;

  /// 화면 아래 버튼 영역. 비우면 영역을 만들지 않습니다.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              // 위의 SafeArea가 홈 인디케이터만큼 이미 띄우므로 여기서는 여백만 둡니다.
              // 아래 버튼 영역이 있으면 목록이 바텀바가 아닌 버튼 위에서 끝납니다.
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: actions.isEmpty
                      ? AppSpacing.scrollEnd
                      : AppSpacing.xl,
                ),
                children: body,
              ),
            ),
            if (actions.isNotEmpty)
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
                      if (index > 0)
                        const SizedBox(height: AppSpacing.buttonGap),
                      action,
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
