import 'package:chagok_mobile/features/chat/data/chat_document.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread_not_found_exception.dart';
import 'package:chagok_mobile/features/chat/data/sample_chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류에 대한 대화를 다루는 창구.
abstract interface class ChatRepository {
  /// 최근에 이야기한 순서대로 정렬한 대화 목록.
  Future<List<ChatThread>> fetchThreads();

  /// [id] 대화를 불러옵니다. 없으면 [ChatThreadNotFoundException]을 던집니다.
  Future<ChatThread> fetchThread(String id);

  /// 새 대화를 엽니다. 인사말이 담긴 대화를 돌려줍니다.
  Future<ChatThread> createThread();

  /// [text]를 보내고 차곡의 답까지 붙은 대화를 돌려줍니다.
  Future<ChatThread> sendMessage({
    required String threadId,
    required String text,
  });

  /// 대화에 연결할 수 있는 서류 목록.
  Future<List<ChatDocument>> fetchDocuments();

  /// 대화에 서류를 연결하고 바뀐 대화를 돌려줍니다.
  Future<ChatThread> linkDocument({
    required String threadId,
    required String documentId,
  });

  /// [document]에 대해 바로 물어볼 만한 질문.
  List<String> suggestedQuestions(ChatDocument? document);
}

/// 앱 전역 [ChatRepository].
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  // TODO: 답변 API가 정해지면 실제 구현으로 바꿉니다.
  return SampleChatRepository(DateTime.now);
});
