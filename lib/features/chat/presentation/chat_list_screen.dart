import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/chat/application/chat_grouping.dart';
import 'package:chagok_mobile/features/chat/application/chat_list_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_search_query_notifier.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_thread_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// H03 · 지난 대화 목록. 채팅 탭의 첫 화면입니다.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  static const _top = 11.0;
  static const _gap = 18.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(filteredChatListProvider);
    final hasQuery = ref.watch(chatSearchQueryProvider).trim().isNotEmpty;
    final now = DateTime.now();

    Future<void> startNewChat() async {
      final id = await ref.read(chatListProvider.notifier).startNewThread();
      if (context.mounted) await context.push(AppRoute.chatRoom(id));
    }

    return Scaffold(
      appBar: const AppTopBar(title: AppTopBar.logoText, showBackButton: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          _top,
          AppSpacing.screenHorizontal,
          AppSpacing.xl,
        ),
        children: [
          const Text(ChatStrings.listTitle, style: AppTypography.pageTitle),
          const SizedBox(height: _gap),
          AppTextField(
            hintText: ChatStrings.searchHint,
            onChanged: ref.read(chatSearchQueryProvider.notifier).update,
            textInputAction: TextInputAction.search,
            suffix: const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
          ...threads.when(
            data: (threads) => _threadSections(
              context,
              threads: threads,
              now: now,
              emptyMessage: hasQuery ? ChatStrings.noResult : ChatStrings.empty,
            ),
            loading: () => const [
              Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (error, stackTrace) => [
              const SizedBox(height: _gap),
              AppButton.secondary(
                label: ChatStrings.retry,
                onPressed: () => ref.invalidate(chatListProvider),
              ),
            ],
          ),
          const SizedBox(height: 44),
          AppButton.primary(
            label: ChatStrings.newChat,
            onPressed: startNewChat,
          ),
        ],
      ),
    );
  }

  List<Widget> _threadSections(
    BuildContext context, {
    required List<ChatThread> threads,
    required DateTime now,
    required String emptyMessage,
  }) {
    if (threads.isEmpty) {
      return [
        const SizedBox(height: _gap),
        Text(emptyMessage, style: AppTypography.pageDescription),
      ];
    }
    final groups = groupByToday(threads, now);
    final latestId = threads.first.id;

    List<Widget> section(String label, List<ChatThread> items) => [
      if (items.isNotEmpty) ...[
        const SizedBox(height: _gap),
        _Eyebrow(label),
        for (final thread in items) ...[
          const SizedBox(height: _gap),
          ChatThreadCard(
            thread: thread,
            now: now,
            isHighlighted: thread.id == latestId,
            onTap: () => context.push(AppRoute.chatRoom(thread.id)),
          ),
        ],
      ],
    ];

    return [
      ...section(ChatStrings.today, groups.today),
      ...section(ChatStrings.earlier, groups.earlier),
    ];
  }
}

/// "오늘", "이전 대화" 같은 작은 구역 이름.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        text,
        style: AppTypography.label.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
          color: AppColors.brand,
        ),
      ),
    );
  }
}
