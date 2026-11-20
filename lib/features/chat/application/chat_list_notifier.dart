import 'package:chagok_mobile/features/chat/application/chat_search_query_notifier.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 대화 목록(H03).
final chatListProvider =
    AsyncNotifierProvider<ChatListNotifier, List<ChatThread>>(
      ChatListNotifier.new,
    );

/// 검색어에 맞는 대화만 남긴 목록.
final filteredChatListProvider = Provider<AsyncValue<List<ChatThread>>>((ref) {
  final query = ref.watch(chatSearchQueryProvider).trim();
  return ref
      .watch(chatListProvider)
      .whenData(
        (threads) => query.isEmpty
            ? threads
            : threads.where((thread) => matchesQuery(thread, query)).toList(),
      );
});

/// 대화 제목·서류 이름·말풍선 글 가운데 하나에 [query]가 들어 있으면 true.
bool matchesQuery(ChatThread thread, String query) {
  final keyword = query.toLowerCase();
  bool contains(String? text) => text?.toLowerCase().contains(keyword) ?? false;
  return contains(thread.document?.name) ||
      thread.messages.any((message) => contains(message.text));
}

/// 대화 목록을 불러옵니다. 새 대화 시작은 `ChatStartNotifier`가 맡습니다.
class ChatListNotifier extends AsyncNotifier<List<ChatThread>> {
  @override
  Future<List<ChatThread>> build() =>
      ref.watch(chatRepositoryProvider).fetchThreads();
}
