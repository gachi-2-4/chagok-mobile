import 'package:chagok_mobile/features/chat/data/chat_thread.dart';

/// 대화 화면(H01)의 상태.
class ChatRoomState {
  const ChatRoomState({
    required this.thread,
    required this.suggestions,
    this.isSending = false,
    this.pendingQuestion,
    this.failedQuestion,
    this.isMissingDocument = false,
  });

  /// 지금 보고 있는 대화.
  final ChatThread thread;

  /// 바로 물어볼 수 있는 질문.
  final List<String> suggestions;

  /// 답을 기다리는 중이면 true.
  final bool isSending;

  /// 답을 기다리는 질문. 서버가 대화를 돌려주기 전까지 내 말풍선으로 먼저 보여 줍니다.
  final String? pendingQuestion;

  /// 답을 받지 못한 마지막 질문. 다시 보낼 수 있게 남겨 둡니다.
  final String? failedQuestion;

  /// 대화에 연결한 서류가 없어 답을 받지 못했으면 true.
  ///
  /// 다시 보내도 같은 결과이므로 화면은 서류를 연결하도록 안내합니다.
  final bool isMissingDocument;

  /// 대화 목록 아래에 내 말풍선으로 덧붙일 질문. 기다리는 질문이나 실패한 질문입니다.
  String? get unansweredQuestion => pendingQuestion ?? failedQuestion;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다.
  ///
  /// [pendingQuestion]·[failedQuestion]은 null로도 바꿀 수 있도록 값을 돌려주는
  /// 함수로 받습니다.
  ChatRoomState copyWith({
    ChatThread? thread,
    bool? isSending,
    String? Function()? pendingQuestion,
    String? Function()? failedQuestion,
    bool? isMissingDocument,
  }) {
    return ChatRoomState(
      thread: thread ?? this.thread,
      suggestions: suggestions,
      isSending: isSending ?? this.isSending,
      pendingQuestion: pendingQuestion != null
          ? pendingQuestion()
          : this.pendingQuestion,
      failedQuestion: failedQuestion != null
          ? failedQuestion()
          : this.failedQuestion,
      isMissingDocument: isMissingDocument ?? this.isMissingDocument,
    );
  }
}
