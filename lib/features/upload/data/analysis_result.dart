import 'package:chagok_mobile/features/upload/data/extracted_field.dart';

/// 서류 분석 결과.
///
/// sealed 클래스라 하위 클래스([AnalysisSucceeded], [AnalysisUnclear])를
/// 이 파일에 함께 둡니다.
sealed class AnalysisResult {
  const AnalysisResult();
}

/// 글자를 읽어 냈습니다.
class AnalysisSucceeded extends AnalysisResult {
  /// [fields]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  /// 넘긴 목록을 나중에 고쳐도 이 결과와 파생 목록은 바뀌지 않습니다.
  AnalysisSucceeded({
    required this.documentType,
    required this.pageCount,
    required List<ExtractedField> fields,
  }) : fields = List.unmodifiable(fields);

  /// 예: "임대차계약서"
  final String documentType;

  /// 서류 전체 페이지 수.
  final int pageCount;

  /// 읽어 낸 조건. 서류에 나온 순서대로이며 바꿀 수 없습니다.
  final List<ExtractedField> fields;

  /// 값을 확실히 읽지 못한 조건.
  List<ExtractedField> get uncertainFields =>
      fields.where((field) => field.isUncertain).toList();

  /// 원본과 다른 이름으로 정리한 조건.
  List<ExtractedField> get renamedFields =>
      fields.where((field) => field.originalLabel != null).toList();
}

/// 사진이 흐려 금액·날짜를 정확히 읽지 못했습니다.
class AnalysisUnclear extends AnalysisResult {
  const AnalysisUnclear();
}
