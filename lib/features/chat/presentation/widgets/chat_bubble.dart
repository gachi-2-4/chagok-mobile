import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_radius.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/features/chat/application/emphasis.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_role.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter/material.dart';

/// 말풍선 하나. 내 질문은 오른쪽 초록, 차곡의 답은 왼쪽 밝은 색입니다.
///
/// 답에 근거가 있으면 아래에 근거와 "원본 확인 ›"을 붙입니다.
class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, this.onViewOriginal, super.key});

  final ChatMessage message;

  /// "원본 확인 ›"을 눌렀을 때 동작.
  final VoidCallback? onViewOriginal;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    // `**굵게**`는 차곡의 답에만 쓰는 표시입니다. 내 질문은 입력한 글자 그대로 보여 줍니다.
    final parts = isUser
        ? [(text: message.text, isBold: false)]
        : splitEmphasis(message.text);
    final source = message.source;

    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: isUser ? AppColors.green : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  for (final part in parts)
                    TextSpan(
                      text: part.text,
                      style: part.isBold
                          ? const TextStyle(fontWeight: FontWeight.w700)
                          : null,
                    ),
                ],
              ),
              style: AppTypography.chatBubble,
            ),
            if (source != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _SourceFooter(source: source, onViewOriginal: onViewOriginal),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(left: isUser ? AppSpacing.chatBubbleIndent : 0),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: isUser
            ? bubble
            : SizedBox(width: double.infinity, child: bubble),
      ),
    );
  }
}

/// 답의 근거와 "원본 확인 ›".
class _SourceFooter extends StatelessWidget {
  const _SourceFooter({required this.source, required this.onViewOriginal});

  /// 예: "계약서 1페이지, 납부 조건"
  final String source;
  final VoidCallback? onViewOriginal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ChatStrings.source(source), style: AppTypography.caption),
        if (onViewOriginal case final onViewOriginal?)
          Semantics(
            button: true,
            child: GestureDetector(
              onTap: onViewOriginal,
              child: const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  ChatStrings.viewOriginal,
                  style: AppTypography.caption,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
