import 'package:chagok_mobile/features/chat/data/chat_role.dart';

/// 대화 말풍선 하나.
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    required this.sentAt,
    this.source,
  });

  final ChatRole role;

  /// 말풍선 글. 차곡의 답에서는 `**굵게**`로 강조할 부분을 표시합니다.
  final String text;
  final DateTime sentAt;

  /// 답의 근거. 예: "계약서 1페이지, 납부 조건"
  final String? source;
}
