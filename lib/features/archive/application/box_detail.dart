import 'package:chagok_mobile/features/archive/application/box_document_item.dart';
import 'package:chagok_mobile/features/archive/data/archive_box.dart';

/// 보관함 상세 화면(06)에 보여 줄 보관함과 담긴 서류.
class BoxDetail {
  /// [documents]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  BoxDetail({required this.box, required List<BoxDocumentItem> documents})
    : documents = List.unmodifiable(documents);

  final ArchiveBox box;

  /// 담은 순서대로 정렬된 서류.
  final List<BoxDocumentItem> documents;
}
