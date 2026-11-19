import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:flutter/material.dart';

/// 파일 고르기·분석·저장이 실패했을 때 보여 주는 안내.
class UploadFailureNotice extends StatelessWidget {
  const UploadFailureNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      UploadStrings.failed,
      textAlign: TextAlign.center,
      style: AppTypography.caption.copyWith(color: AppColors.danger),
    );
  }
}
