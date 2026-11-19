import 'dart:async';

import 'package:chagok_mobile/features/chat/application/chat_start_notifier.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_chat_repository.dart';

void main() {
  late FakeChatRepository repository;

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    // autoDispose provider가 테스트 도중 사라지지 않게 구독해 둡니다.
    container.listen(chatStartProvider, (_, _) {});
    return container;
  }

  setUp(() {
    repository = FakeChatRepository();
  });

  group('ChatStartNotifier', () {
    test('처음 읽으면 아무 작업도 하지 않은 상태다', () {
      final container = createContainer();

      final state = container.read(chatStartProvider);

      expect(state, isA<AsyncData<void>>());
    });

    test('새 대화를 시작하면 대화를 만들고 그 id를 돌려준다', () async {
      final container = createContainer();

      final id = await container.read(chatStartProvider.notifier).start();

      expect(repository.threads.keys, contains(id));
      expect(container.read(chatStartProvider), isA<AsyncData<void>>());
    });

    test('시작하는 동안에는 로딩 상태이고 또 부르면 무시하고 null을 돌려준다', () async {
      final container = createContainer();
      repository.createGate = Completer<void>();
      final notifier = container.read(chatStartProvider.notifier);

      final first = notifier.start();
      final second = await notifier.start();

      expect(container.read(chatStartProvider).isLoading, isTrue);
      expect(second, isNull);
      repository.createGate?.complete();
      await first;
      expect(repository.threads, hasLength(1));
    });

    test('대화를 만들지 못하면 에러 상태가 되고 null을 돌려준다', () async {
      final container = createContainer();
      repository.createError = Exception('network');

      final id = await container.read(chatStartProvider.notifier).start();

      expect(id, isNull);
      expect(container.read(chatStartProvider).hasError, isTrue);
    });

    test('실패한 뒤 다시 시작해 성공하면 에러 상태가 풀린다', () async {
      final container = createContainer();
      final notifier = container.read(chatStartProvider.notifier);
      repository.createError = Exception('network');
      await notifier.start();

      repository.createError = null;
      final id = await notifier.start();

      expect(id, isNotNull);
      expect(container.read(chatStartProvider).hasError, isFalse);
    });
  });
}
