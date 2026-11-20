import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:flutter/material.dart';

/// 아래에서 올라오는 시트 맨 위의 끌어 내리는 손잡이.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  static const _width = 36.0;
  static const _height = 4.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        color: AppColors.chipBorder,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}
