import 'package:chagok_mobile/features/archive/application/archive_dates.dart';
import 'package:chagok_mobile/features/archive/application/archive_today_notifier.dart';
import 'package:chagok_mobile/features/archive/application/box_detail.dart';
import 'package:chagok_mobile/features/archive/application/box_document_item.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 보관함 하나의 상세 내용. 화면을 벗어나면 버립니다.
final boxDetailProvider = AsyncNotifierProvider.autoDispose
    .family<BoxDetailNotifier, BoxDetail, String>(BoxDetailNotifier.new);

/// 보관함 [boxId]와 담긴 서류를 불러옵니다.
class BoxDetailNotifier extends AsyncNotifier<BoxDetail> {
  BoxDetailNotifier(this.boxId);

  final String boxId;

  @override
  Future<BoxDetail> build() async {
    // 날짜가 바뀌면 D-n 기준이 달라지므로 다시 불러옵니다.
    final today = ref.watch(archiveTodayProvider);
    final repository = ref.watch(archiveRepositoryProvider);
    // 함께 기다리면(Future.wait) 실패가 ParallelWaitError로 감싸져
    // 보관함이 없다는 예외를 알아보기 어려우므로 차례로 가져옵니다.
    final box = await repository.fetchBox(boxId, today);
    final documents = await repository.fetchDocuments(boxId, today);
    return BoxDetail(
      box: box,
      documents: [
        for (final document in documents)
          BoxDocumentItem(
            document: document,
            daysLeft: ArchiveDates.daysLeft(document.dueDate, today),
          ),
      ],
    );
  }
}
