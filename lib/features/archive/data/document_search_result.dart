import 'package:chagok_mobile/features/archive/data/box_document.dart';

/// 서류 검색 결과 하나. 서류와 그 서류가 담긴 보관함 이름입니다.
class DocumentSearchResult {
  const DocumentSearchResult({required this.document, required this.boxName});

  final BoxDocument document;

  /// 서류가 담긴 보관함 이름. 예: "집 · 임대"
  final String boxName;
}
