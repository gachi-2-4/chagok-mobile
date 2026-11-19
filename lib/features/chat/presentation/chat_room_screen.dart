import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_banner.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_chip.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_state.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// H01 · 서류에 대해 묻고 답을 받는 대화 화면.
class ChatRoomScreen extends ConsumerWidget {
  const ChatRoomScreen({required this.threadId, super.key});

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
          onSend: ref.read(provider.notifier).send,
          onAddDocument: () => context.push(AppRoute.chatAttach(threadId)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(ChatStrings.loadFailed, style: AppTypography.body),
                const SizedBox(height: AppSpacing.lg),
                AppButton.secondary(
                  label: ChatStrings.retry,
                  onPressed: () => ref.invalidate(provider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatRoomBody extends StatelessWidget {
  const _ChatRoomBody({
    required this.state,
    required this.onSend,
    required this.onAddDocument,
  });

  final ChatRoomState state;
  final ValueChanged<String> onSend;
  final VoidCallback onAddDocument;

  static const _top = 11.0;
  static const _gap = 18.0;
  static const _inputBottom = 16.0;

  @override
  Widget build(BuildContext context) {
    final thread = state.thread;
    final document = thread.document;
    final messages = thread.messages;

    void showComingSoon() {
      // TODO: 원본 보기 화면이 생기면 근거 페이지로 연결합니다.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(ChatStrings.comingSoon)));
    }

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              // 새 말풍선이 생기면 아래쪽이 보이도록 거꾸로 쌓습니다.
              reverse: true,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                _top,
                AppSpacing.screenHorizontal,
                _gap,
              ),
              children: [
                for (final widget in [
                  const Text(
                    ChatStrings.roomTitle,
                    style: AppTypography.pageTitle,
                  ),
                  GestureDetector(
                    onTap: onAddDocument,
                    child: AppBanner(
                      child: Text(
                        document == null
                            ? '${ChatStrings.noLinkedDocument}　${ChatStrings.change}'
                            : '${ChatStrings.linkedDocument(document.name)}'
                                  '　${ChatStrings.change}',
                      ),
                    ),
                  ),
                  for (final (index, message) in messages.indexed) ...[
                    ChatBubble(
                      message: message,
                      onViewOriginal: showComingSoon,
                    ),
                    // 첫 인사 바로 아래에 바로 물어볼 질문을 둡니다.
                    if (index == 0 && message.role == ChatRole.assistant)
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final question in state.suggestions)
                            AppChip(
                              label: question,
                              onTap: state.isSending
                                  ? null
                                  : () => onSend(question),
                            ),
                        ],
                      ),
                  ],
                  if (state.isSending)
                    const Text(
                      ChatStrings.typing,
                      style: AppTypography.caption,
                    ),
                ].reversed) ...[widget, const SizedBox(height: _gap)],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              _inputBottom,
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
