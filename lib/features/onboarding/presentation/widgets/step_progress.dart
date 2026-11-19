import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 설문이 몇 단계 중 어디까지 왔는지 보여 주는 짧은 막대들.
///
/// Figma `div.progress`에 해당합니다. 지나온 단계와 지금 단계는 주황입니다.
class StepProgress extends StatelessWidget {
  const StepProgress({
    required this.current,
    required this.total,
    required this.semanticLabel,
    super.key,
  });

  /// 지금 단계(1부터 셉니다).
  final int current;
  final int total;

  /// 화면 읽기 프로그램이 읽어 줄 진행 상황. 예: "4단계 중 2단계"
  final String semanticLabel;

  static const _segmentWidth = 28.0;
  static const _segmentHeight = 5.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Row(
        children: [
          for (var index = 0; index < total; index++) ...[
            if (index > 0) const SizedBox(width: _gap),
            Container(
              width: _segmentWidth,
              height: _segmentHeight,
              decoration: BoxDecoration(
                color: index < current ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(_segmentHeight),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
