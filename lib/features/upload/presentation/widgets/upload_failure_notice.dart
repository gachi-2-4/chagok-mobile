import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/upload/presentation/upload_strings.dart';
import 'package:flutter/material.dart';

/// 파일 고르기·분석·저장이 실패했을 때 보여 주는 안내.
class UploadFailureNotice extends StatelessWidget {
  const UploadFailureNotice({this.message = UploadStrings.failed, super.key});

  /// 보여 줄 안내. 비우면 "처리하지 못했어요" 안내입니다.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: AppTypography.caption.copyWith(color: AppColors.danger),
    );
  }
}
