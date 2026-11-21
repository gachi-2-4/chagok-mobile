import 'package:chagok_mobile/features/archive/data/summary_section.dart';

/// AI가 서류를 읽고 정리한 내용(AI 정리본).
class DocumentSummary {
  /// [sections]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  DocumentSummary({
    required this.oneLine,
    required List<SummarySection> sections,
  }) : sections = List.unmodifiable(sections);

  /// 서류를 쉬운 말로 줄인 한두 문장.
  final String oneLine;

  /// 서류에 쓰인 순서대로 정리한 구역.
  final List<SummarySection> sections;
}
