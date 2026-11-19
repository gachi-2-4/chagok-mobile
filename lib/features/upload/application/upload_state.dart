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
    this.hasFailed = false,
  });

  /// 고른 파일. 아직 고르지 않았으면 null.
  final PickedDocument? document;

  /// 담을 수 있는 보관함.
  final List<DocumentBox> boxes;

  /// 고른 보관함 id. 아직 고르지 않았으면 null.
  final String? selectedBoxId;

  /// 마지막 분석 결과. 아직 분석하지 않았으면 null.
  final AnalysisResult? result;

  /// 파일 고르기·분석·저장 중이면 true.
  final bool isBusy;

  /// 마지막 파일 고르기·분석·저장이 실패했으면 true.
  final bool hasFailed;

  /// [selectedBoxId]에 맞는 보관함. 고르지 않았거나 목록에 없으면 null.
  DocumentBox? get selectedBox {
    for (final box in boxes) {
      if (box.id == selectedBoxId) return box;
    }
    return null;
  }

  /// 파일과 보관함을 골랐고 다른 일을 하는 중이 아니면 true.
  bool get canAnalyze => document != null && selectedBox != null && !isBusy;

  /// 분석에 성공했고 보관함을 골랐으며 다른 일을 하는 중이 아니면 true.
  bool get canSave =>
      document != null &&
      selectedBox != null &&
      result is AnalysisSucceeded &&
      !isBusy;

  /// 넘긴 값만 바꾼 새 상태를 돌려줍니다. [result]는 null로도 바꿀 수 있게 함수로 받습니다.
  UploadState copyWith({
    PickedDocument? document,
    List<DocumentBox>? boxes,
    String? selectedBoxId,
    AnalysisResult? Function()? result,
    bool? isBusy,
    bool? hasFailed,
  }) {
    return UploadState(
      document: document ?? this.document,
      boxes: boxes ?? this.boxes,
      selectedBoxId: selectedBoxId ?? this.selectedBoxId,
      result: result == null ? this.result : result(),
      isBusy: isBusy ?? this.isBusy,
      hasFailed: hasFailed ?? this.hasFailed,
    );
  }
}
