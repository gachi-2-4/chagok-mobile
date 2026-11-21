import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/application/document_search_notifier.dart';
import 'package:chagok_mobile/features/archive/application/document_search_query_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_archive_repository.dart';

void main() {
  late FakeArchiveRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeArchiveRepository(
      boxes: [
        const ArchiveBox(
          id: 'housing',
          name: '집 · 임대',
          color: BoxColor.peach,
          icon: BoxIcon.home,
          documentCount: 1,
        ),
      ],
      documents: {
        'housing': [
          BoxDocument(
            id: 'fee',
            title: '11월 관리비 고지서',
            importance: DocumentImportance.medium,
            pageCount: 1,
            dueDate: DateTime(2026, 12, 3),
          ),
        ],
      },
    );
    container = ProviderContainer(
      overrides: [
        archiveRepositoryProvider.overrideWithValue(repository),
        archiveClockProvider.overrideWithValue(() => DateTime(2026, 11, 20, 9)),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
    // 검색 화면이 열려 있는 동안처럼 검색어와 결과를 계속 듣습니다.
    final querySubscription = container.listen(
      documentSearchQueryProvider,
      (_, _) {},
    );
    addTearDown(querySubscription.close);
    final resultSubscription = container.listen(
      documentSearchProvider,
      (_, _) {},
    );
    addTearDown(resultSubscription.close);
  });

  void search(String query) =>
      container.read(documentSearchQueryProvider.notifier).update(query);

  group('DocumentSearchNotifier', () {
    test('검색어가 비어 있으면 저장소를 부르지 않고 빈 목록을 돌려준다', () async {
      search('   ');

      final items = await container.read(documentSearchProvider.future);

      expect(items, isEmpty);
      expect(repository.searchQueries, isEmpty);
    });

    test('검색어를 적으면 앞뒤 공백을 빼고 찾는다', () async {
      search(' 관리비 ');

      await container.read(documentSearchProvider.future);

      expect(repository.searchQueries, ['관리비']);
    });

    test('맞는 서류가 있으면 보관함 이름과 남은 날을 함께 돌려준다', () async {
      search('관리비');

      final items = await container.read(documentSearchProvider.future);

      expect(items.single.document.id, 'fee');
      expect(items.single.boxName, '집 · 임대');
      expect(items.single.daysLeft, 13);
    });

    test('저장소가 실패하면 에러 상태가 된다', () async {
      repository.searchError = Exception('네트워크 오류');
      search('관리비');

      await expectLater(
        container.read(documentSearchProvider.future),
        throwsA(isA<Exception>()),
      );
      expect(container.read(documentSearchProvider).hasError, isTrue);
    });
  });
}
