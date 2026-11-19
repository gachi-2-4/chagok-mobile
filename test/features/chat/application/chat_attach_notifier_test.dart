import 'dart:async';

import 'package:chagok_mobile/features/chat/application/chat_attach_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_room_notifier.dart';
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
    );
    addTearDown(container.dispose);
    // autoDispose provider가 테스트 도중 사라지지 않게 구독해 둡니다.
    container.listen(chatAttachProvider(threadId), (_, _) {});
    return container;
  }

  setUp(() {
    repository = FakeChatRepository(
      threads: [buildThread(id: threadId, question: '월세는 언제 내나요?')],
    );
  });

  group('ChatAttachNotifier.build', () {
    test('고를 수 있는 서류를 불러오고 아무것도 고르지 않은 상태로 시작한다', () async {
      final container = createContainer();

      final state = await container.read(chatAttachProvider(threadId).future);

      expect(state.documents, [leaseDocument, maintenanceDocument]);
      expect(state.selected, isNull);
    });
  });

  group('ChatAttachNotifier.select', () {
    test('서류를 고르면 selected가 그 서류가 된다', () async {
      final container = createContainer();
      await container.read(chatAttachProvider(threadId).future);

      container
          .read(chatAttachProvider(threadId).notifier)
          .select('maintenance');

      expect(
        container.read(chatAttachProvider(threadId)).requireValue.selected,
        maintenanceDocument,
      );
    });

    test('다른 서류를 다시 고르면 선택이 바뀐다', () async {
      final container = createContainer();
      await container.read(chatAttachProvider(threadId).future);
      final notifier = container.read(chatAttachProvider(threadId).notifier);

      notifier
        ..select('lease')
        ..select('maintenance');

      expect(
        container.read(chatAttachProvider(threadId)).requireValue.selectedId,
        'maintenance',
      );
    });
  });

  group('ChatAttachNotifier.attach', () {
    test('서류를 고르지 않았으면 연결하지 않고 false를 돌려준다', () async {
      final container = createContainer();
      await container.read(chatAttachProvider(threadId).future);

      final isAttached = await container
          .read(chatAttachProvider(threadId).notifier)
          .attach();

      expect(isAttached, isFalse);
      expect(repository.linkedDocuments, isEmpty);
    });

    test('고른 서류를 대화에 연결하고 true를 돌려준다', () async {
      final container = createContainer();
      await container.read(chatAttachProvider(threadId).future);
      final notifier = container.read(chatAttachProvider(threadId).notifier)
        ..select('maintenance');

      final isAttached = await notifier.attach();

      expect(isAttached, isTrue);
      expect(repository.linkedDocuments.single, (
        threadId: threadId,
        documentId: 'maintenance',
      ));
    });

    test('연결하는 동안 isSaving이 true이고 끝나면 false로 돌아온다', () async {
      final container = createContainer();
      await container.read(chatAttachProvider(threadId).future);
      repository.linkGate = Completer<void>();
      final notifier = container.read(chatAttachProvider(threadId).notifier)
        ..select('lease');

      final attaching = notifier.attach();

      expect(
        container.read(chatAttachProvider(threadId)).requireValue.isSaving,
        isTrue,
      );
      repository.linkGate?.complete();
      await attaching;
      expect(
        container.read(chatAttachProvider(threadId)).requireValue.isSaving,
        isFalse,
      );
    });

    test('연결하는 중에 또 부르면 무시하고 false를 돌려준다', () async {
      final container = createContainer();
      await container.read(chatAttachProvider(threadId).future);
      repository.linkGate = Completer<void>();
      final notifier = container.read(chatAttachProvider(threadId).notifier)
        ..select('lease');

      final first = notifier.attach();
      final isSecondAttached = await notifier.attach();
      repository.linkGate?.complete();
      await first;

      expect(isSecondAttached, isFalse);
      expect(repository.linkedDocuments, hasLength(1));
    });

    test('연결하고 나면 대화 화면이 연결된 서류를 다시 불러온다', () async {
      final container = createContainer();
      container.listen(chatRoomProvider(threadId), (_, _) {});
      final before = await container.read(chatRoomProvider(threadId).future);
      await container.read(chatAttachProvider(threadId).future);
      final notifier = container.read(chatAttachProvider(threadId).notifier)
        ..select('maintenance');

      await notifier.attach();
      final after = await container.read(chatRoomProvider(threadId).future);

      expect(before.thread.document, isNull);
      expect(after.thread.document, maintenanceDocument);
    });
  });
}
