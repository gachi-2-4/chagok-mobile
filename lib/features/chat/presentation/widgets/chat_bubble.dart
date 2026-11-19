import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/chat/application/emphasis.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter/material.dart';

/// 말풍선 하나. 내 질문은 오른쪽 초록, 차곡의 답은 왼쪽 밝은 색입니다.
///
/// 답에 근거가 있으면 아래에 근거와 "원본 확인 ›"을 붙입니다.
class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, this.onViewOriginal, super.key});

  final ChatMessage message;
  final VoidCallback? onViewOriginal;

  static const _padding = 16.0;

  /// 내 질문 말풍선 왼쪽을 비워 두는 너비.
  static const _userIndent = 45.0;

  /// Figma 말풍선 글자: 14 / 줄 높이 23.8
  static const _textStyle = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontFamilyFallback: AppTypography.fontFamilyFallback,
    fontSize: 14,
    height: 23.8 / 14,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final source = message.source;

    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: isUser ? AppColors.green : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  for (final part in splitEmphasis(message.text))
                    TextSpan(
                      text: part.text,
                      style: part.isBold
                          ? const TextStyle(fontWeight: FontWeight.w700)
                          : null,
                    ),
                ],
              ),
              style: _textStyle,
            ),
            if (source != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(ChatStrings.source(source), style: AppTypography.caption),
              GestureDetector(
                onTap: onViewOriginal,
                child: const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    ChatStrings.viewOriginal,
                    style: AppTypography.caption,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(left: isUser ? _userIndent : 0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: isUser
            ? bubble
            : SizedBox(width: double.infinity, child: bubble),
      ),
    );
  }
}
