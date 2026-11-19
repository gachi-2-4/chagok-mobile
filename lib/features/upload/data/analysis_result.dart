import 'package:chagok_mobile/features/upload/data/extracted_field.dart';

/// 서류 분석 결과.
sealed class AnalysisResult {
  const AnalysisResult();
}

/// 글자를 읽어 냈습니다.
class AnalysisSucceeded extends AnalysisResult {
  const AnalysisSucceeded({
    required this.documentType,
    required this.pageCount,
    required this.fields,
  });

  /// 예: "임대차계약서"
  final String documentType;
  final int pageCount;
  final List<ExtractedField> fields;

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
