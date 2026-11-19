import 'dart:async';

import 'package:chagok_mobile/features/chat/application/chat_list_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_notifier.dart';
import 'package:chagok_mobile/features/chat/data/chat_message.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_chat_repository.dart';

void main() {
  const threadId = 'thread-1';
  late FakeChatRepository repository;

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(repository)],
      // 에러 상태를 바로 확인하려고 자동 재시도를 끕니다.
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    // autoDispose provider가 테스트 도중 사라지지 않게 구독해 둡니다.
    container.listen(chatRoomProvider(threadId), (_, _) {});
    return container;
  }

  setUp(() {
    repository = FakeChatRepository(
      threads: [
        buildThread(
          id: threadId,
          question: '월세는 언제 내나요?',
          document: leaseDocument,
        ),
      ],
    );
  });

  group('ChatRoomNotifier.build', () {
    test('대화와 서류에 맞는 추천 질문을 불러온다', () async {
      final container = createContainer();

      final state = await container.read(chatRoomProvider(threadId).future);

      expect(state.thread.id, threadId);
      expect(state.suggestions, ['임대차계약서에 대해 물어보기']);
      expect(state.isSending, isFalse);
    });

    test('없는 대화면 에러 상태가 된다', () async {
      final container = createContainer();
      container.listen(chatRoomProvider('missing'), (_, _) {});

      await expectLater(
        container.read(chatRoomProvider('missing').future),
        throwsA(isA<ChatThreadNotFoundException>()),
      );
      expect(container.read(chatRoomProvider('missing')).hasError, isTrue);
    });
  });

  group('ChatRoomNotifier.send', () {
    test('질문을 보내면 질문과 답이 대화에 붙는다', () async {
      final container = createContainer();
      await container.read(chatRoomProvider(threadId).future);

      await container
          .read(chatRoomProvider(threadId).notifier)
          .send('위약금이 있나요?');

      final messages = container
          .read(chatRoomProvider(threadId))
          .requireValue
          .thread
          .messages;
      expect(messages[messages.length - 2].role, ChatRole.user);
      expect(messages[messages.length - 2].text, '위약금이 있나요?');
      expect(messages.last.text, '답: 위약금이 있나요?');
    });

    test('앞뒤 공백을 지우고 보낸다', () async {
      final container = createContainer();
      await container.read(chatRoomProvider(threadId).future);

      await container
          .read(chatRoomProvider(threadId).notifier)
          .send('  위약금이 있나요?  ');

      expect(repository.sentMessages.single.text, '위약금이 있나요?');
    });

    test('빈 글이나 공백만 있으면 보내지 않는다', () async {
      final container = createContainer();
      await container.read(chatRoomProvider(threadId).future);
      final notifier = container.read(chatRoomProvider(threadId).notifier);

      await notifier.send('');
      await notifier.send('   ');

      expect(repository.sentMessages, isEmpty);
    });

    test('답을 기다리는 동안 isSending이 true다', () async {
      final container = createContainer();
      await container.read(chatRoomProvider(threadId).future);
      repository.sendGate = Completer<void>();

      final sending = container
          .read(chatRoomProvider(threadId).notifier)
          .send('위약금이 있나요?');

      expect(
        container.read(chatRoomProvider(threadId)).requireValue.isSending,
        isTrue,
      );
      repository.sendGate?.complete();
      await sending;
      expect(
        container.read(chatRoomProvider(threadId)).requireValue.isSending,
        isFalse,
      );
    });

    test('답을 기다리는 중에 또 보내면 무시한다', () async {
      final container = createContainer();
      await container.read(chatRoomProvider(threadId).future);
      repository.sendGate = Completer<void>();
      final notifier = container.read(chatRoomProvider(threadId).notifier);

      final first = notifier.send('첫 질문');
      await notifier.send('두 번째 질문');
      repository.sendGate?.complete();
      await first;

      expect(repository.sentMessages.map((sent) => sent.text), ['첫 질문']);
    });

    test('답을 받지 못하면 보내는 중 상태를 풀고 실패한 질문을 남긴다', () async {
      final container = createContainer();
      final before = await container.read(chatRoomProvider(threadId).future);
      repository.sendError = Exception('network');

      await container
          .read(chatRoomProvider(threadId).notifier)
          .send('위약금이 있나요?');

      final state = container.read(chatRoomProvider(threadId)).requireValue;
      expect(state.isSending, isFalse);
      expect(state.failedQuestion, '위약금이 있나요?');
      expect(state.thread.messages, before.thread.messages);
    });

    test('실패한 뒤 다시 보내 답을 받으면 실패 표시가 사라진다', () async {
      final container = createContainer();
      await container.read(chatRoomProvider(threadId).future);
      final notifier = container.read(chatRoomProvider(threadId).notifier);
      repository.sendError = Exception('network');
      await notifier.send('위약금이 있나요?');

      repository.sendError = null;
      await notifier.send('위약금이 있나요?');

      final state = container.read(chatRoomProvider(threadId)).requireValue;
      expect(state.failedQuestion, isNull);
      expect(state.thread.messages.last.text, '답: 위약금이 있나요?');
    });

    test('다시 보내는 동안에는 실패 표시를 숨긴다', () async {
      final container = createContainer();
      await container.read(chatRoomProvider(threadId).future);
      final notifier = container.read(chatRoomProvider(threadId).notifier);
      repository.sendError = Exception('network');
      await notifier.send('위약금이 있나요?');
      repository
        ..sendError = null
        ..sendGate = Completer<void>();

      final sending = notifier.send('위약금이 있나요?');

      expect(
        container.read(chatRoomProvider(threadId)).requireValue.failedQuestion,
        isNull,
      );
      repository.sendGate?.complete();
      await sending;
    });

    test('답을 받지 못하면 대화 목록을 다시 불러오지 않는다', () async {
      final container = createContainer();
      container.listen(chatListProvider, (_, _) {});
      await container.read(chatListProvider.future);
      await container.read(chatRoomProvider(threadId).future);
      repository.sendError = Exception('network');

      await container
          .read(chatRoomProvider(threadId).notifier)
          .send('위약금이 있나요?');
      await container.read(chatListProvider.future);

      expect(repository.fetchThreadsCount, 1);
    });

    test('보내고 나면 대화 목록을 다시 불러온다', () async {
      final container = createContainer();
      container.listen(chatListProvider, (_, _) {});
      await container.read(chatListProvider.future);
      await container.read(chatRoomProvider(threadId).future);

      await container
          .read(chatRoomProvider(threadId).notifier)
          .send('위약금이 있나요?');
      await container.read(chatListProvider.future);

      expect(repository.fetchThreadsCount, 2);
    });
  });
}
