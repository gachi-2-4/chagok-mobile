import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_banner.dart';
import 'package:chagok_mobile/core/widgets/app_chip.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_state.dart';
import 'package:chagok_mobile/features/chat/data/chat_document.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_role.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_load_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// H01 · 서류에 대해 묻고 답을 받는 대화 화면.
class ChatRoomScreen extends ConsumerWidget {
  const ChatRoomScreen({required this.threadId, super.key});

  /// 보여 줄 대화 id.
  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatRoomProvider(threadId);
    final value = ref.watch(provider);

    return Scaffold(
      appBar: const AppTopBar(title: AppTopBar.logoText),
      body: value.when(
        data: (state) => _ChatRoomBody(
          state: state,
          onSend: (text) => unawaited(ref.read(provider.notifier).send(text)),
          onAddDocument: () =>
              unawaited(context.push(AppRoute.chatAttach(threadId))),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: ChatLoadError(
              message: ChatStrings.loadFailed,
              onRetry: () => ref.invalidate(provider),
            ),
          ),
        ),
      ),
    );
  }
}

/// 말풍선 목록과 아래 입력줄.
class _ChatRoomBody extends StatelessWidget {
  const _ChatRoomBody({
    required this.state,
    required this.onSend,
    required this.onAddDocument,
  });

  final ChatRoomState state;
  final ValueChanged<String> onSend;
  final VoidCallback onAddDocument;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: _MessageList(
              state: state,
              onSend: onSend,
              // 답을 기다리는 중에 서류를 바꾸면 대화를 다시 불러오면서
              // 도착할 답이 화면에서 빠질 수 있어 막습니다.
              onAddDocument: state.isSending ? null : onAddDocument,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              AppSpacing.lg,
            ),
            child: ChatInputBar(
              onSend: onSend,
              onAddDocument: onAddDocument,
              isEnabled: !state.isSending,
            ),
          ),
        ],
      ),
    );
  }
}

/// 제목·연결된 서류·말풍선·추천 질문을 위에서부터 쌓은 목록.
class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.state,
    required this.onSend,
    required this.onAddDocument,
  });

  final ChatRoomState state;
  final ValueChanged<String> onSend;

  /// null이면 서류 띠를 누를 수 없습니다.
  final VoidCallback? onAddDocument;

  @override
  Widget build(BuildContext context) {
    final messages = state.thread.messages;

    // 근거 쪽까지는 아직 알 수 없어, 대화에 연결한 서류의 원본을 엽니다.
    final document = state.thread.document;
    final viewOriginal = document == null
        ? null
        : () => unawaited(context.push(AppRoute.document(document.id)));

    final items = [
      const Text(ChatStrings.roomTitle, style: AppTypography.pageTitle),
      _DocumentBanner(document: state.thread.document, onTap: onAddDocument),
      for (final (index, message) in messages.indexed) ...[
        ChatBubble(message: message, onViewOriginal: viewOriginal),
        // 첫 인사 바로 아래에 바로 물어볼 질문을 둡니다.
        if (index == 0 && message.role == ChatRole.assistant)
          _SuggestionChips(
            questions: state.suggestions,
            onSelect: state.isSending ? null : onSend,
          ),
      ],
      // 보낸 질문은 답을 받기 전이나 받지 못했을 때도 내 말풍선으로 남깁니다.
      if (state.unansweredQuestion case final question?)
        _UnansweredBubble(question: question),
      if (state.isSending)
        const Text(ChatStrings.typing, style: AppTypography.caption),
      if (state.failedQuestion case final question?)
        _SendFailedNotice(
          isMissingDocument: state.isMissingDocument,
          onResend: () => onSend(question),
          onAddDocument: onAddDocument,
        ),
    ];

    return ListView(
      // 새 말풍선이 생기면 아래쪽이 보이도록 거꾸로 쌓습니다.
      reverse: true,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.pageTop,
        AppSpacing.screenHorizontal,
        AppSpacing.block,
      ),
      children: [
        for (final item in items.reversed) ...[
          item,
          const SizedBox(height: AppSpacing.block),
        ],
      ],
    );
  }
}

/// 대화에 연결된 서류와 "변경 ›". 누르면 서류 추가 화면으로 갑니다.
class _DocumentBanner extends StatelessWidget {
  const _DocumentBanner({required this.document, required this.onTap});

  final ChatDocument? document;

  /// null이면 누를 수 없습니다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppBanner(child: Text(ChatStrings.documentBanner(document?.name))),
    );
  }
}

/// 바로 물어볼 수 있는 질문 칩. [onSelect]가 null이면 누를 수 없습니다.
class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.questions, required this.onSelect});

  final List<String> questions;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    final onSelect = this.onSelect;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final question in questions)
          AppChip(
            label: question,
            onTap: onSelect == null ? null : () => onSelect(question),
          ),
      ],
    );
  }
}

/// 서버가 아직 대화에 넣어 돌려주지 않은 내 질문 말풍선.
class _UnansweredBubble extends StatelessWidget {
  const _UnansweredBubble({required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    return ChatBubble(
      // 시각은 말풍선에 보이지 않아 지금 시각을 넣습니다.
      message: ChatMessage(
        role: ChatRole.user,
        text: question,
        sentAt: DateTime.now(),
      ),
    );
  }
}

/// 답을 받지 못했을 때 보이는 안내와 다음 동작 버튼.
///
/// 대화에 서류가 없어 실패했으면 다시 보내도 같으므로 "서류 추가"를,
/// 아니면 "다시 보내기"를 보여 줍니다.
class _SendFailedNotice extends StatelessWidget {
  const _SendFailedNotice({
    required this.isMissingDocument,
    required this.onResend,
    required this.onAddDocument,
  });

  final bool isMissingDocument;
  final VoidCallback onResend;

  /// null이면 "서류 추가"를 누를 수 없습니다.
  final VoidCallback? onAddDocument;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMissingDocument
              ? ChatStrings.sendNeedsDocument
              : ChatStrings.sendFailed,
          style: AppTypography.caption.copyWith(color: AppColors.danger),
        ),
        const SizedBox(height: AppSpacing.sm),
        isMissingDocument
            ? AppChip(label: ChatStrings.addDocument, onTap: onAddDocument)
            : AppChip(label: ChatStrings.resend, onTap: onResend),
      ],
    );
  }
}
