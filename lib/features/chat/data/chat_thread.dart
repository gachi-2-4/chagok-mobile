import 'package:chagok_mobile/features/chat/data/chat_document.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';

/// 대화 하나.
class ChatThread {
  const ChatThread({
    required this.id,
    required this.messages,
    required this.updatedAt,
    this.document,
  });

  final String id;

  /// 대화에 연결된 서류. 없으면 null.
  final ChatDocument? document;
  final List<ChatMessage> messages;
  final DateTime updatedAt;

  /// 목록에 보일 제목. 처음 물어본 질문입니다.
  String? get title {
    for (final message in messages) {
      if (message.role == ChatRole.user) return message.text;
    }
    return null;
  }

  ChatThread copyWith({
    ChatDocument? document,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) {
    return ChatThread(
      id: id,
      document: document ?? this.document,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
