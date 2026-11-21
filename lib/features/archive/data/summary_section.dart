import 'package:chagok_mobile/features/archive/data/summary_row.dart';

/// AI 정리본의 구역 하나. 이름·값 표이거나 점 목록입니다.
sealed class SummarySection {
  const SummarySection({required this.title});

  /// 구역 이름. 예: "계약 개요", "주요 특약"
  final String title;
}

/// 이름·값 표로 보여 주는 구역. 예: 계약 개요
class SummaryTable extends SummarySection {
  /// [rows]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  SummaryTable({required super.title, required List<SummaryRow> rows})
    : rows = List.unmodifiable(rows);

  final List<SummaryRow> rows;
}

/// 점(•) 목록으로 보여 주는 구역. 예: 주요 특약, 체크
class SummaryList extends SummarySection {
  /// [items]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  SummaryList({required super.title, required List<String> items})
    : items = List.unmodifiable(items);

  final List<String> items;
}
