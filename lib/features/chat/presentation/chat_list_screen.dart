import 'dart:async';

import 'package:chagok_mobile/app/router.dart';
import 'package:chagok_mobile/core/constants/app_colors.dart';
import 'package:chagok_mobile/core/constants/app_icons.dart';
import 'package:chagok_mobile/core/constants/app_spacing.dart';
import 'package:chagok_mobile/core/constants/app_typography.dart';
import 'package:chagok_mobile/core/extensions/scroll_end_inset.dart';
import 'package:chagok_mobile/core/widgets/app_button.dart';
import 'package:chagok_mobile/core/widgets/app_text_field.dart';
import 'package:chagok_mobile/core/widgets/app_top_bar.dart';
import 'package:chagok_mobile/features/chat/application/chat_grouping.dart';
import 'package:chagok_mobile/features/chat/application/chat_list_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_search_query_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_start_notifier.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:chagok_mobile/features/chat/presentation/chat_strings.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_load_error.dart';
import 'package:chagok_mobile/features/chat/presentation/widgets/chat_thread_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// H03 · 지난 대화 목록. 채팅 탭의 첫 화면입니다.
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(filteredChatListProvider);
    final hasQuery = ref.watch(chatSearchQueryProvider).trim().isNotEmpty;

    return Scaffold(
      appBar: const AppTopBar(title: AppTopBar.logoText, showBackButton: false),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.pageTop,
          AppSpacing.screenHorizontal,
          context.scrollEndInset(),
        ),
        children: [
          const Text(ChatStrings.listTitle, style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.block),
          AppTextField(
            hintText: ChatStrings.searchHint,
            onChanged: (query) =>
                ref.read(chatSearchQueryProvider.notifier).update(query),
            textInputAction: TextInputAction.search,
            suffix: const Icon(
              Icons.search_rounded,
              size: AppIcons.mediumSize,
              color: AppColors.textPrimary,
            ),
          ),
          threads.when(
            data: (threads) => _ThreadSections(
              threads: threads,
              now: DateTime.now(),
              emptyMessage: hasQuery ? ChatStrings.noResult : ChatStrings.empty,
              onOpen: (id) => unawaited(context.push(AppRoute.chatRoom(id))),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.block),
              child: ChatLoadError(
                message: ChatStrings.listLoadFailed,
                onRetry: () => ref.invalidate(chatListProvider),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.primaryActionTop),
          const _NewChatAction(),
        ],
      ),
    );
  }
}

/// "새 대화 시작" 버튼과 실패 안내. 시작하는 동안에는 버튼을 막습니다.
class _NewChatAction extends ConsumerWidget {
  const _NewChatAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (isStarting, hasFailed) = ref
        .watch(chatStartProvider)
        .when(
          data: (_) => (false, false),
          loading: () => (true, false),
          error: (error, stackTrace) => (false, true),
        );

    Future<void> startNewChat() async {
      final id = await ref.read(chatStartProvider.notifier).start();
      if (id == null || !context.mounted) return;
      // 채팅 탭은 indexedStack에 남아 있어 다른 탭으로 가도 mounted가 true입니다.
      // 아직 대화 목록을 보고 있을 때만 대화방으로 이동해, 다른 화면 위에 열지 않습니다.
      final location = GoRouter.of(context)
          .routerDelegate
          .currentConfiguration
          .uri
          .path;
      if (location != AppRoute.chat) return;
      await context.push(AppRoute.chatRoom(id));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasFailed) ...[
          Text(
            ChatStrings.newChatFailed,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: AppSpacing.buttonGap),
        ],
        AppButton.primary(
          label: ChatStrings.newChat,
          onPressed: isStarting ? null : () => unawaited(startNewChat()),
        ),
      ],
    );
  }
}

/// 대화를 "오늘"과 "이전 대화"로 나눈 목록. 대화가 없으면 [emptyMessage]를 보여 줍니다.
class _ThreadSections extends StatelessWidget {
  const _ThreadSections({
    required this.threads,
    required this.now,
    required this.emptyMessage,
    required this.onOpen,
  });

  final List<ChatThread> threads;
  final DateTime now;
  final String emptyMessage;

  /// 대화를 누르면 그 id를 받습니다.
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (threads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.block),
        child: Text(emptyMessage, style: AppTypography.pageDescription),
      );
    }
    final groups = groupByToday(threads, now);
    final latestId = threads.first.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, items) in [
          (ChatStrings.today, groups.today),
          (ChatStrings.earlier, groups.earlier),
        ])
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.block),
            _Eyebrow(text: label),
            for (final thread in items) ...[
              const SizedBox(height: AppSpacing.block),
              ChatThreadCard(
                thread: thread,
                now: now,
                isHighlighted: thread.id == latestId,
                onTap: () => onOpen(thread.id),
              ),
            ],
          ],
      ],
    );
  }
}

/// "오늘", "이전 대화" 같은 작은 구역 이름.
class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.eyebrowTop),
      child: Text(text, style: AppTypography.eyebrow),
    );
  }
}
