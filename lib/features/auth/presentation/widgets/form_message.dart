import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:flutter/material.dart';

/// 입력창 아래나 버튼 위에 붙는 작은 안내·오류 문구.
///
/// [isError]가 true면 경고 색으로 보여 줍니다.
class FormMessage extends StatelessWidget {
  const FormMessage(this.text, {this.isError = false, super.key});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.caption.copyWith(
        color: isError ? AppColors.danger : AppColors.textTertiary,
      ),
    );
  }
}
