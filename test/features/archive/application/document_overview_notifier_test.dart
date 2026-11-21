import 'package:chagok_mobile/features/archive/application/archive_clock.dart';
import 'package:chagok_mobile/features/archive/application/archive_today_notifier.dart';
import 'package:chagok_mobile/features/archive/application/document_overview_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_document_not_found_exception.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';
import 'package:chagok_mobile/features/archive/data/document_overview.dart';
import 'package:chagok_mobile/features/archive/data/document_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_archive_repository.dart';

void main() {
  late FakeArchiveRepository repository;
  late ProviderContainer container;
  late DateTime now;

  DocumentOverview overview({DateTime? dueDate}) => DocumentOverview(
    document: BoxDocument(
      id: 'lease',
      title: '전세 임대차 계약서',
      importance: DocumentImportance.high,
      pageCount: 4,
      dueDate: dueDate,
    ),
    box: const ArchiveBox(
      id: 'housing',
      name: '집 · 임대',
      color: BoxColor.peach,
      icon: BoxIcon.home,
      documentCount: 1,
    ),
    summary: DocumentSummary(oneLine: '요약', sections: const []),
  );

  setUp(() {
    now = DateTime(2026, 11, 20, 9);
    repository = FakeArchiveRepository(
      overviews: {'lease': overview(dueDate: DateTime(2027, 1, 5))},
    );
    container = ProviderContainer(
      overrides: [
        archiveRepositoryProvider.overrideWithValue(repository),
        archiveClockProvider.overrideWithValue(() => now),
      ],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  group('DocumentOverviewNotifier', () {
    test('불러오면 서류 상세와 기한까지 남은 날을 돌려준다', () async {
      final item = await container.read(
        documentOverviewProvider('lease').future,
      );

      expect(item.overview.document.title, '전세 임대차 계약서');
      expect(item.daysLeft, 46);
    });

    test('기한이 없는 서류면 남은 날은 null이다', () async {
      repository.overviews['lease'] = overview();

      final item = await container.read(
        documentOverviewProvider('lease').future,
      );

      expect(item.daysLeft, isNull);
    });

    test('날짜가 바뀌면 남은 날을 새 날짜 기준으로 다시 센다', () async {
      final subscription = container.listen(
        documentOverviewProvider('lease'),
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(documentOverviewProvider('lease').future);

      now = DateTime(2026, 11, 21, 0, 1);
      container.read(archiveTodayProvider.notifier).refresh();

      final item = await container.read(
        documentOverviewProvider('lease').future,
      );
      expect(item.daysLeft, 45);
    });

    test('없는 서류를 열면 BoxDocumentNotFoundException 에러 상태가 된다', () async {
      final subscription = container.listen(
        documentOverviewProvider('missing'),
        (_, _) {},
      );
      addTearDown(subscription.close);

      await expectLater(
        container.read(documentOverviewProvider('missing').future),
        throwsA(isA<BoxDocumentNotFoundException>()),
      );
      expect(
        container.read(documentOverviewProvider('missing')).error,
        isA<BoxDocumentNotFoundException>(),
      );
    });
  });
}
