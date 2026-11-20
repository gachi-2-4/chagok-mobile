import 'package:chagok_mobile/features/chat/application/chat_room_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_chat_repository.dart';

void main() {
  final thread = buildThread(id: 't1', question: '월세는 언제 내나요?');

  group('ChatRoomState.copyWith', () {
    test('아무 값도 넘기지 않으면 모든 값을 그대로 둔다', () {
      final state = ChatRoomState(
        thread: thread,
        suggestions: const ['위약금이 있나요?'],
        isSending: true,
        failedQuestion: '언제 내나요?',
      );

      final copied = state.copyWith();

      expect(copied.thread, same(thread));
      expect(copied.suggestions, ['위약금이 있나요?']);
      expect(copied.isSending, isTrue);
      expect(copied.failedQuestion, '언제 내나요?');
    });

    test('failedQuestion에 null을 돌려주는 함수를 넘기면 실패한 질문을 지운다', () {
      final state = ChatRoomState(
        thread: thread,
        suggestions: const [],
        failedQuestion: '언제 내나요?',
      );

      final copied = state.copyWith(failedQuestion: () => null);

      expect(copied.failedQuestion, isNull);
    });

    test('failedQuestion에 질문을 돌려주는 함수를 넘기면 그 질문으로 바꾼다', () {
      final state = ChatRoomState(thread: thread, suggestions: const []);

      final copied = state.copyWith(failedQuestion: () => '위약금이 있나요?');

      expect(copied.failedQuestion, '위약금이 있나요?');
    });
  });
}
