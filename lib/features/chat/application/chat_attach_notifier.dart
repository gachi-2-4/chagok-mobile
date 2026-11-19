import 'package:chagok_mobile/features/chat/application/chat_attach_state.dart';
import 'package:chagok_mobile/features/chat/application/chat_list_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_notifier.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:flutter/foundation.dart';
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

  /// [documentId] 서류를 고릅니다. 앞선 연결 실패 표시는 지웁니다.
  ///
  /// 연결하는 중에는 무시합니다. 연결 결과가 어느 서류의 것인지 헷갈리지 않게 합니다.
  void select(String documentId) {
    final current = state.value;
    if (current == null || current.isSaving) return;
    state = AsyncData(
      current.copyWith(selectedId: documentId, hasAttachFailed: false),
    );
  }

  /// 고른 서류를 대화에 연결합니다. 연결했으면 true.
  ///
  /// 연결하지 못하면 고른 서류는 그대로 두고
  /// [ChatAttachState.hasAttachFailed]를 켠 뒤 false를 돌려줍니다.
  Future<bool> attach() async {
    final current = state.value;
    final selected = current?.selected;
    if (current == null || selected == null || current.isSaving) return false;
    // 연결하는 중에 화면을 닫아도 대화·목록을 갱신할 수 있도록,
    // 끝날 때까지 provider를 살려 둡니다.
    final keepAlive = ref.keepAlive();
    state = AsyncData(current.copyWith(isSaving: true, hasAttachFailed: false));
    try {
      await ref
          .read(chatRepositoryProvider)
          .linkDocument(threadId: threadId, documentId: selected.id);
      if (ref.mounted) {
        // 대화 화면의 서류 띠와 목록 검색이 새 서류 이름을 쓰도록 다시 불러옵니다.
        ref
          ..invalidate(chatRoomProvider(threadId))
          ..invalidate(chatListProvider);
        state = AsyncData(
          current.copyWith(isSaving: false, hasAttachFailed: false),
        );
      }
      return true;
    } catch (error, stackTrace) {
      debugPrint('서류를 연결하지 못했습니다: $error\n$stackTrace');
      if (ref.mounted) {
        state = AsyncData(
          current.copyWith(isSaving: false, hasAttachFailed: true),
        );
      }
      return false;
    } finally {
      keepAlive.close();
    }
  }
}
