import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/document_box.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';

/// 서류 올리기 흐름(U01~U04)의 상태.
class UploadState {
  const UploadState({
    this.document,
    this.boxes = const [],
    this.selectedBoxId,
    this.result,
    this.isBusy = false,
  });

  /// 고른 파일. 아직 고르지 않았으면 null.
  final PickedDocument? document;

  /// 담을 수 있는 보관함.
  final List<DocumentBox> boxes;
  final String? selectedBoxId;

  /// 마지막 분석 결과. 아직 분석하지 않았으면 null.
  final AnalysisResult? result;

  /// 파일 고르기·분석·저장 중이면 true.
  final bool isBusy;

  DocumentBox? get selectedBox {
    for (final box in boxes) {
      if (box.id == selectedBoxId) return box;
    }
    return null;
  }

  bool get canAnalyze => document != null && selectedBox != null && !isBusy;

  bool get canSave =>
      document != null &&
      selectedBox != null &&
      result is AnalysisSucceeded &&
      !isBusy;

  UploadState copyWith({
    PickedDocument? document,
    List<DocumentBox>? boxes,
    String? selectedBoxId,
    AnalysisResult? Function()? result,
    bool? isBusy,
  }) {
    return UploadState(
      document: document ?? this.document,
      boxes: boxes ?? this.boxes,
      selectedBoxId: selectedBoxId ?? this.selectedBoxId,
      result: result == null ? this.result : result(),
      isBusy: isBusy ?? this.isBusy,
    );
  }
}
