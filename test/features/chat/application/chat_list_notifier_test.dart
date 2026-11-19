import 'package:chagok_mobile/features/chat/application/chat_list_notifier.dart';
import 'package:chagok_mobile/features/chat/application/chat_search_query_notifier.dart';
import 'package:chagok_mobile/features/chat/data/chat_repository.dart';
import 'package:chagok_mobile/features/chat/data/chat_thread.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_chat_repository.dart';

void main() {
  final leaseThread = buildThread(
    id: 'lease-thread',
    question: '월세는 언제 내나요?',
    document: leaseDocument,
  );
  final maintenanceThread = buildThread(
    id: 'maintenance-thread',
    question: '왜 달라졌나요?',
    document: maintenanceDocument,
  );

  late FakeChatRepository repository;

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    repository = FakeChatRepository(threads: [leaseThread, maintenanceThread]);
  });

  group('ChatListNotifier', () {
    test('처음 읽으면 저장소의 대화 목록을 불러온다', () async {
      final container = createContainer();

      final threads = await container.read(chatListProvider.future);

      expect(threads, [leaseThread, maintenanceThread]);
    });

    test('startNewThread를 부르면 새 대화를 만들고 그 id를 돌려준다', () async {
      final container = createContainer();

      final id = await container
          .read(chatListProvider.notifier)
          .startNewThread();

      expect(repository.threads.keys, contains(id));
    });
  });

  group('filteredChatListProvider', () {
    Future<List<ChatThread>> readFiltered(
      ProviderContainer container,
      String query,
    ) async {
      container.read(chatSearchQueryProvider.notifier).update(query);
      await container.read(chatListProvider.future);
      return container.read(filteredChatListProvider).requireValue;
    }

    test('검색어가 비어 있으면 모든 대화를 돌려준다', () async {
      final container = createContainer();

      final threads = await readFiltered(container, '');

      expect(threads, [leaseThread, maintenanceThread]);
    });

    test('검색어에 맞는 대화만 남긴다', () async {
      final container = createContainer();

      final threads = await readFiltered(container, '관리비');

      expect(threads, [maintenanceThread]);
    });

    test('검색어 앞뒤 공백은 무시한다', () async {
      final container = createContainer();

      final threads = await readFiltered(container, '  월세  ');

      expect(threads, [leaseThread]);
    });

    test('공백만 넣으면 모든 대화를 돌려준다', () async {
      final container = createContainer();

      final threads = await readFiltered(container, '   ');

      expect(threads, hasLength(2));
    });

    test('목록을 불러오는 중이면 로딩 상태를 그대로 전한다', () {
      final container = createContainer();

      final filtered = container.read(filteredChatListProvider);

      expect(filtered.isLoading, isTrue);
    });
  });

  group('matchesQuery', () {
    test('서류 이름에 검색어가 들어 있으면 true다', () {
      expect(matchesQuery(leaseThread, '임대차'), isTrue);
    });

    test('말풍선 글에 검색어가 들어 있으면 true다', () {
      expect(matchesQuery(leaseThread, '언제'), isTrue);
    });

    test('영문은 대소문자를 가리지 않는다', () {
      final thread = buildThread(id: 't', question: 'PDF 파일이 안 열려요');

      expect(matchesQuery(thread, 'pdf'), isTrue);
    });

    test('어디에도 검색어가 없으면 false다', () {
      expect(matchesQuery(leaseThread, '보험'), isFalse);
    });

    test('서류가 없는 대화도 말풍선 글로 찾는다', () {
      final thread = buildThread(id: 't', question: '위약금이 있나요?');

      expect(matchesQuery(thread, '위약금'), isTrue);
      expect(matchesQuery(thread, '임대차'), isFalse);
    });
  });
}
