import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 서류 미리 보기처럼 생긴 밝은 종이 상자.
///
/// Figma `div.preview`에 해당합니다. U02에서는 서류 내용을, U03에서는
/// 촬영 안내를 담습니다.
class DocumentPreviewCard extends StatelessWidget {
  const DocumentPreviewCard({required this.child, this.minHeight, super.key});

  final Widget child;
  final double? minHeight;

  static const _radius = 16.0;
  static const _padding = 20.0;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.dialogSurface,
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: AppColors.chipBorder),
        ),
        child: Padding(padding: const EdgeInsets.all(_padding), child: child),
      ),
    );
  }
}
