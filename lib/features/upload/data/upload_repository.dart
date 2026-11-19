import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/document_box.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/sample_upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류를 고르고, 분석하고, 보관함에 담는 창구.
abstract interface class UploadRepository {
  /// [source]에서 파일을 고릅니다. 사용자가 취소하면 null.
  Future<PickedDocument?> pick(UploadSource source);

  /// 서류를 담을 수 있는 보관함 목록.
  Future<List<DocumentBox>> fetchBoxes();

  Future<AnalysisResult> analyze(PickedDocument document);

  /// 분석 결과를 확인한 서류를 [boxId] 보관함에 담습니다.
  Future<void> save({
    required PickedDocument document,
    required AnalysisSucceeded result,
    required String boxId,
  });
}

/// 앱 전역 [UploadRepository].
final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  // TODO: 카메라·앨범·파일 선택 플러그인과 분석 API가 정해지면 바꿉니다.
  return SampleUploadRepository();
});
