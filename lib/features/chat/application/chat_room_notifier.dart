import 'package:chagok_mobile/features/chat/application/chat_list_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_state.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 대화 하나의 상태.
final chatRoomProvider = AsyncNotifierProvider.autoDispose
    .family<ChatRoomNotifier, ChatRoomState, String>(ChatRoomNotifier.new);

/// 대화를 불러오고 질문을 보냅니다.
class ChatRoomNotifier extends AsyncNotifier<ChatRoomState> {
  ChatRoomNotifier(this.threadId);

  final String threadId;

  @override
  Future<ChatRoomState> build() async {
    final repository = ref.watch(chatRepositoryProvider);
    final thread = await repository.fetchThread(threadId);
    return ChatRoomState(
      thread: thread,
      suggestions: repository.suggestedQuestions(thread.document),
    );
  }

  /// [text]를 보내고 답을 받습니다. 빈 글이거나 답을 기다리는 중이면 무시합니다.
  Future<void> send(String text) async {
    final current = state.value;
    final question = text.trim();
    if (current == null || current.isSending || question.isEmpty) return;
    state = AsyncData(current.copyWith(isSending: true));
    final thread = await ref
        .read(chatRepositoryProvider)
        .sendMessage(threadId: threadId, text: question);
    if (!ref.mounted) return;
    state = AsyncData(current.copyWith(thread: thread, isSending: false));
    ref.invalidate(chatListProvider);
  }
}
