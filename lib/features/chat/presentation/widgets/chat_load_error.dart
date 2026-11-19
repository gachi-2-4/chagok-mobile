import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter/material.dart';

/// 불러오기에 실패했을 때 보여 주는 안내와 "다시 시도" 버튼.
class ChatLoadError extends StatelessWidget {
  const ChatLoadError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  /// 사용자에게 보여 줄 안내. 예: "대화를 불러오지 못했어요."
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, style: AppTypography.body),
        const SizedBox(height: AppSpacing.lg),
        AppButton.secondary(label: ChatStrings.retry, onPressed: onRetry),
      ],
    );
  }
}
