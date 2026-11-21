import 'package:chagok_mobile/features/archive/data/document_importance.dart';

/// 보관함에 담긴 서류 하나.
class BoxDocument {
  const BoxDocument({
    required this.id,
    required this.title,
    required this.importance,
    required this.pageCount,
    this.dueDate,
  });

  final String id;

  /// 예: "전세 임대차 계약서"
  final String title;
  final DocumentImportance importance;

  /// 원본 쪽수. 1보다 크면 서류 원본 위에 "4장"처럼 표시합니다.
  final int pageCount;

  /// 납부·만기일. 없으면 null.
  final DateTime? dueDate;
}
