import 'package:chagok_mobile/features/archive/application/archive_dates.dart';
import 'package:chagok_mobile/features/archive/application/archive_today_notifier.dart';
import 'package:chagok_mobile/features/archive/application/document_overview_item.dart';
import 'package:chagok_mobile/features/archive/data/archive_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류 하나의 상세 내용과 AI 정리본. 화면을 벗어나면 버립니다.
final documentOverviewProvider = AsyncNotifierProvider.autoDispose
    .family<DocumentOverviewNotifier, DocumentOverviewItem, String>(
      DocumentOverviewNotifier.new,
    );

/// 서류 [documentId]의 상세 내용을 불러옵니다. 날짜가 바뀌면 D-day를 다시 셉니다.
class DocumentOverviewNotifier extends AsyncNotifier<DocumentOverviewItem> {
  DocumentOverviewNotifier(this.documentId);

  final String documentId;

  @override
  Future<DocumentOverviewItem> build() async {
    final today = ref.watch(archiveTodayProvider);
    final overview = await ref
        .watch(archiveRepositoryProvider)
        .fetchDocumentOverview(documentId, today);
    return DocumentOverviewItem(
      overview: overview,
      daysLeft: ArchiveDates.daysLeft(overview.document.dueDate, today),
    );
  }
}
