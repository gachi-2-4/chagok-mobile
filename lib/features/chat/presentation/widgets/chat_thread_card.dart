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
  final DateTime now;
  final VoidCallback onTap;
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
        const SizedBox(height: 10),
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
