import 'package:chagok_mobile/features/chat/data/chat_thread.dart';

/// 대화 화면(H01)의 상태.
class ChatRoomState {
  const ChatRoomState({
    required this.thread,
    required this.suggestions,
    this.isSending = false,
    this.failedQuestion,
  });

  /// 지금 보고 있는 대화.
  final ChatThread thread;

  /// 바로 물어볼 수 있는 질문.
  final List<String> suggestions;

  /// 답을 기다리는 중이면 true.
  final bool isSending;

  /// 답을 받지 못한 마지막 질문. 다시 보낼 수 있게 남겨 둡니다.
  final String? failedQuestion;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다.
  ///
  /// [failedQuestion]은 null로도 바꿀 수 있도록 값을 돌려주는 함수로 받습니다.
  ChatRoomState copyWith({
    ChatThread? thread,
    bool? isSending,
    String? Function()? failedQuestion,
  }) {
    return ChatRoomState(
      thread: thread ?? this.thread,
      suggestions: suggestions,
      isSending: isSending ?? this.isSending,
      failedQuestion: failedQuestion != null
          ? failedQuestion()
          : this.failedQuestion,
    );
  }
}
