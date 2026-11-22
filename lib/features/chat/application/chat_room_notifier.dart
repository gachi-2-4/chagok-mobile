import 'package:chagok_mobile/features/chat/application/chat_list_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_state.dart';
import 'package:chagok_mobile/features/chat/data/chat_no_document_exception.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:flutter/foundation.dart';
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
  ///
  /// 답을 받지 못하면 대화는 그대로 두고 [ChatRoomState.failedQuestion]에
  /// 질문을 남깁니다. 화면 전체를 에러로 바꾸지 않아 이전 대화를 계속 볼 수 있습니다.
  /// 대화에 서류가 없어 실패했으면 [ChatRoomState.isMissingDocument]도 켭니다.
  Future<void> send(String text) async {
    final current = state.value;
    final question = text.trim();
    if (current == null || current.isSending || question.isEmpty) return;
    // 답을 기다리는 중에 대화방을 나가도 결과를 반영하고 대화 목록을
    // 갱신할 수 있도록, 끝날 때까지 provider를 살려 둡니다.
    final keepAlive = ref.keepAlive();
    state = AsyncData(
      current.copyWith(
        isSending: true,
        pendingQuestion: () => question,
        failedQuestion: () => null,
        isMissingDocument: false,
      ),
    );
    try {
      final thread = await ref
          .read(chatRepositoryProvider)
          .sendMessage(threadId: threadId, text: question);
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          thread: thread,
          isSending: false,
          pendingQuestion: () => null,
          failedQuestion: () => null,
          isMissingDocument: false,
        ),
      );
      ref.invalidate(chatListProvider);
    } catch (error, stackTrace) {
      debugPrint('질문을 보내지 못했습니다: $error\n$stackTrace');
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          isSending: false,
          pendingQuestion: () => null,
          failedQuestion: () => question,
          isMissingDocument: error is ChatNoDocumentException,
        ),
      );
    } finally {
      keepAlive.close();
    }
  }
}
