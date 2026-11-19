import 'package:chagok_mobile/features/chat/application/chat_attach_state.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_notifier.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 대화 하나에 서류를 추가하는 화면의 상태.
final chatAttachProvider = AsyncNotifierProvider.autoDispose
    .family<ChatAttachNotifier, ChatAttachState, String>(
      ChatAttachNotifier.new,
    );

/// 보관함 서류를 골라 대화에 연결합니다.
class ChatAttachNotifier extends AsyncNotifier<ChatAttachState> {
  ChatAttachNotifier(this.threadId);

  final String threadId;

  @override
  Future<ChatAttachState> build() async {
    final documents = await ref.watch(chatRepositoryProvider).fetchDocuments();
    return ChatAttachState(documents: documents);
  }

  void select(String documentId) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(selectedId: documentId));
    }
  }

  /// 고른 서류를 대화에 연결합니다. 연결했으면 true.
  Future<bool> attach() async {
    final current = state.value;
    final selected = current?.selected;
    if (current == null || selected == null || current.isSaving) return false;
    state = AsyncData(current.copyWith(isSaving: true));
    await ref
        .read(chatRepositoryProvider)
        .linkDocument(threadId: threadId, documentId: selected.id);
    ref.invalidate(chatRoomProvider(threadId));
    if (ref.mounted) state = AsyncData(current);
    return true;
  }
}
