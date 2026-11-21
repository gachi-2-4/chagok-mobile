import 'package:chagok_mobile/features/archive/data/box_document.dart';

/// 보관함 상세·검색 결과에 보여 줄 서류 하나와 기한까지 남은 날.
class BoxDocumentItem {
  const BoxDocumentItem({
    required this.document,
    required this.daysLeft,
    this.boxName,
  });

  final BoxDocument document;

  /// 기한까지 남은 날. 기한이 없거나 지났으면 null.
  final int? daysLeft;

  /// 검색 결과처럼 여러 보관함의 서류를 섞어 보여 줄 때 담긴 보관함 이름.
  /// 보관함 상세에서는 null입니다.
  final String? boxName;
}
