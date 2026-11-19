import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_card.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:flutter/material.dart';

/// 대화 목록의 대화 하나. 가장 최근 대화는 초록으로 강조합니다.
class ChatThreadCard extends StatelessWidget {
  const ChatThreadCard({
    required this.thread,
    required this.now,
    required this.onTap,
    this.isHighlighted = false,
    super.key,
  });

  final ChatThread thread;

  /// 시각 표시 기준. 오늘이면 시각, 아니면 날짜를 보여 줍니다.
  final DateTime now;
  final VoidCallback onTap;

  /// true면 초록 카드로 강조합니다.
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final documentName = thread.document?.name;
    final updatedAt = ChatStrings.updatedAt(thread.updatedAt, now);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(
            thread.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.cardTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.cardTitleGap),
        Text(
          documentName == null ? updatedAt : '$documentName · $updatedAt',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.pageDescription,
        ),
      ],
    );

    return isHighlighted
        ? AppCard.green(onTap: onTap, child: content)
        : AppCard(onTap: onTap, child: content);
  }
}
