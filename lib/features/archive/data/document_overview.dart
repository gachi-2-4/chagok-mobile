import 'package:chagok_mobile/features/archive/data/archive_box.dart';
import 'package:chagok_mobile/features/archive/data/box_document.dart';
import 'package:chagok_mobile/features/archive/data/document_cost.dart';
import 'package:chagok_mobile/features/archive/data/document_summary.dart';

/// 서류 상세 화면(07·08)에 보여 줄 서류 하나의 내용.
class DocumentOverview {
  const DocumentOverview({
    required this.document,
    required this.box,
    required this.summary,
    this.cost,
    this.dueLabel,
    this.periodEnd,
  });

  /// 이름·중요도·쪽수·기한을 담은 서류.
  final BoxDocument document;

  /// 서류가 담긴 보관함.
  final ArchiveBox box;

  /// AI 정리본.
  final DocumentSummary summary;

  /// 대표 금액. 없으면 null이고 비용 줄을 그리지 않습니다.
  final DocumentCost? cost;

  /// 기한([BoxDocument.dueDate])이 무슨 날인지. 예: "갱신 통보", "납부"
  final String? dueLabel;

  /// 계약·이용 기간이 끝나는 날. 예: 2027.02.28. 없으면 null.
  final DateTime? periodEnd;
}
