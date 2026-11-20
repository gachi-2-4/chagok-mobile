import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/application/box_detail_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/box_not_found_exception.dart';
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
          documentCount: 2,
        ),
      ],
      documents: {
        'housing': [
          BoxDocument(
            id: 'lease',
            title: '전세 임대차 계약서',
            importance: DocumentImportance.high,
            pageCount: 4,
            dueDate: DateTime(2027, 1, 5),
          ),
          const BoxDocument(
            id: 'move-in',
            title: '전입신고 확인서',
            importance: DocumentImportance.low,
            pageCount: 1,
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
  });

  group('BoxDetailNotifier', () {
    test('불러오면 보관함과 서류를 담은 순서대로 돌려준다', () async {
      final detail = await container.read(boxDetailProvider('housing').future);

      expect(detail.box.name, '집 · 임대');
      expect(detail.documents.map((item) => item.document.id), [
        'lease',
        'move-in',
      ]);
    });

    test('불러오면 서류마다 기한까지 남은 날을 센다', () async {
      final detail = await container.read(boxDetailProvider('housing').future);

      expect(detail.documents.map((item) => item.daysLeft), [46, null]);
    });

    test('없는 보관함을 열면 BoxNotFoundException 에러 상태가 된다', () async {
      final subscription = container.listen(
        boxDetailProvider('missing'),
        (_, _) {},
      );
      addTearDown(subscription.close);

      await expectLater(
        container.read(boxDetailProvider('missing').future),
        throwsA(isA<BoxNotFoundException>()),
      );
      expect(
        container.read(boxDetailProvider('missing')).error,
        isA<BoxNotFoundException>(),
      );
    });
  });
}
