import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/document_search_result.dart';
import 'package:chagok_mobile/features/archive/data/sample_archive_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 보관함과 그 안의 서류를 가져오고 찾으며, 새 보관함을 만드는 창구.
abstract interface class ArchiveRepository {
  /// [today] 기준으로 내 보관함을 모두 가져옵니다. 만든 순서대로입니다.
  Future<List<ArchiveBox>> fetchBoxes(DateTime today);

  /// 보관함 [boxId]를 가져옵니다.
  ///
  /// 없으면 `BoxNotFoundException`을 던집니다.
  Future<ArchiveBox> fetchBox(String boxId, DateTime today);

  /// 보관함 [boxId]에 담긴 서류를 가져옵니다. 담은 순서대로입니다.
  ///
  /// 보관함이 없으면 `BoxNotFoundException`을 던집니다.
  Future<List<BoxDocument>> fetchDocuments(String boxId, DateTime today);

  /// 이름이나 내용에 [query]가 들어간 서류를 모든 보관함에서 찾습니다.
  ///
  /// 띄어쓰기와 영문 대소문자는 가리지 않습니다. 보관함 순서, 그 안에서는
  /// 담은 순서대로 돌려줍니다.
  Future<List<DocumentSearchResult>> searchDocuments(
    String query,
    DateTime today,
  );

  /// 서류 [documentId]의 내용을 AI로 쉬운 말로 바꿔 돌려줍니다.
  ///
  /// 서류가 없으면 `BoxDocumentNotFoundException`을 던집니다.
  Future<String> translateToPlainLanguage(String documentId);

  /// 빈 보관함을 만들고 돌려줍니다.
  Future<ArchiveBox> createBox({
    required String name,
    required BoxColor color,
    required BoxIcon icon,
  });
}

/// 앱 전역 [ArchiveRepository].
final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) {
  // TODO: 백엔드가 정해지면 실제 구현으로 바꿉니다.
  return SampleArchiveRepository();
});
