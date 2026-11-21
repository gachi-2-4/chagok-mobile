import 'package:chagok_mobile/features/archive/application/archive_dates.dart';
import 'package:chagok_mobile/features/archive/application/archive_today_notifier.dart';
import 'package:chagok_mobile/features/archive/application/box_document_item.dart';
import 'package:chagok_mobile/features/archive/application/document_search_query_notifier.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 지금 검색어에 맞는 서류. 검색 화면을 벗어나면 버립니다.
final documentSearchProvider =
    AsyncNotifierProvider.autoDispose<
      DocumentSearchNotifier,
      List<BoxDocumentItem>
    >(DocumentSearchNotifier.new);

/// 검색어가 바뀔 때마다 이름이나 내용이 맞는 서류를 다시 찾습니다.
///
/// 검색어가 비어 있으면 찾지 않고 빈 목록을 돌려줍니다.
class DocumentSearchNotifier extends AsyncNotifier<List<BoxDocumentItem>> {
  @override
  Future<List<BoxDocumentItem>> build() async {
    final query = ref.watch(documentSearchQueryProvider).trim();
    if (query.isEmpty) return const [];
    // TODO: 서버 검색을 붙이면 글자마다 요청하지 않도록 잠시 기다렸다가 찾습니다.
    // 날짜가 바뀌면 D-n 기준이 달라지므로 다시 찾습니다.
    final today = ref.watch(archiveTodayProvider);
    final results = await ref
        .watch(archiveRepositoryProvider)
        .searchDocuments(query, today);
    return [
      for (final result in results)
        BoxDocumentItem(
          document: result.document,
          daysLeft: ArchiveDates.daysLeft(result.document.dueDate, today),
          boxName: result.boxName,
        ),
    ];
  }
}
