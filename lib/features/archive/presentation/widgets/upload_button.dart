import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/features/archive/presentation/archive_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 보관함 화면 오른쪽 아래에 떠 있는 서류 올리기(스캔) 버튼.
class UploadButton extends StatelessWidget {
  const UploadButton({super.key});

  static const _iconSize = 26.0;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => unawaited(context.push(AppRoute.upload)),
      tooltip: ArchiveStrings.upload,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      highlightElevation: 0,
      shape: const CircleBorder(),
      child: const Icon(Icons.document_scanner_outlined, size: _iconSize),
    );
  }
}
