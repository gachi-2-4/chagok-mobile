import 'package:chagok_mobile/features/chat/data/chat_document.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_role.dart';

/// 대화 하나.
class ChatThread {
  /// [messages]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  /// 넘긴 목록을 나중에 고쳐도 이 대화는 바뀌지 않습니다.
  ChatThread({
    required this.id,
    required List<ChatMessage> messages,
    required this.updatedAt,
    this.document,
  }) : messages = List.unmodifiable(messages);

  final String id;

  /// 대화에 연결된 서류. 없으면 null.
  final ChatDocument? document;

  /// 말풍선 목록. 바꿀 수 없습니다. 바꾸려면 [copyWith]로 새 대화를 만듭니다.
  final List<ChatMessage> messages;
  final DateTime updatedAt;

  /// 목록에 보일 제목. 처음 물어본 질문입니다.
  String? get title {
    for (final message in messages) {
      if (message.role == ChatRole.user) return message.text;
    }
    return null;
  }

  /// 넘긴 값만 바꾼 새 대화를 돌려줍니다. [id]는 바꿀 수 없습니다.
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
