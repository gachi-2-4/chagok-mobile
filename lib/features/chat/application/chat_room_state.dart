import 'package:chagok_mobile/features/chat/data/chat_thread.dart';

/// 대화 화면(H01)의 상태.
class ChatRoomState {
  const ChatRoomState({
    required this.thread,
    required this.suggestions,
    this.isSending = false,
  });

  final ChatThread thread;

  /// 바로 물어볼 수 있는 질문.
  final List<String> suggestions;

  /// 답을 기다리는 중이면 true.
  final bool isSending;

  ChatRoomState copyWith({ChatThread? thread, bool? isSending}) {
    return ChatRoomState(
      thread: thread ?? this.thread,
      suggestions: suggestions,
      isSending: isSending ?? this.isSending,
    );
  }
}
