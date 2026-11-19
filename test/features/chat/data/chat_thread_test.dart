import 'package:chagok_mobile/features/chat/data/chat_document.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_role.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime(2026, 11, 19, 10);
  const document = ChatDocument(
    id: 'lease',
    name: '임대차계약서',
    fileName: '임대차계약서.pdf',
  );

  ChatMessage message(ChatRole role, String text) =>
      ChatMessage(role: role, text: text, sentAt: at);

  group('ChatThread.title', () {
    test('사용자 질문이 여러 개면 처음 물어본 질문을 제목으로 쓴다', () {
      final thread = ChatThread(
        id: 't1',
        updatedAt: at,
        messages: [
          message(ChatRole.assistant, '안녕하세요'),
          message(ChatRole.user, '월세는 언제 내나요?'),
          message(ChatRole.assistant, '25일이에요'),
          message(ChatRole.user, '위약금이 있나요?'),
        ],
      );

      expect(thread.title, '월세는 언제 내나요?');
    });

    test('사용자 말풍선이 없으면 null이다', () {
      final thread = ChatThread(
        id: 't1',
        updatedAt: at,
        messages: [message(ChatRole.assistant, '안녕하세요')],
      );

      expect(thread.title, isNull);
    });
  });

  group('ChatThread.copyWith', () {
    test('copyWith로 일부 값을 넘기면 그 값만 바꾸고 나머지는 그대로 둔다', () {
      final thread = ChatThread(
        id: 't1',
        updatedAt: at,
        messages: [message(ChatRole.assistant, '안녕하세요')],
      );
      final later = at.add(const Duration(minutes: 5));

      final updated = thread.copyWith(document: document, updatedAt: later);

      expect(updated.id, 't1');
      expect(updated.document, document);
      expect(updated.updatedAt, later);
      expect(updated.messages, same(thread.messages));
    });
  });
}
