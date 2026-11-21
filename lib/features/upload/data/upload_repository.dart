import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/api_upload_repository.dart';
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

  /// [document]를 [boxId] 보관함에 올리고 글자를 읽어 조건을 정리합니다.
  ///
  /// 서버는 올릴 때 보관함을 정해야 해서 분석 전에 [boxId]를 받습니다. 보관은
  /// 사용자가 분석 결과를 확인하고 [save]를 불러야 끝납니다.
  Future<AnalysisResult> analyze(
    PickedDocument document, {
    required String boxId,
  });

  /// 분석 결과를 확인한 서류를 [boxId] 보관함에 담습니다.
  Future<void> save({
    required PickedDocument document,
    required AnalysisSucceeded result,
    required String boxId,
  });
}

/// 앱 전역 [UploadRepository].
///
/// API 서버 주소가 있으면 서버에 올려 분석하고, 없으면 예시 결과를 돌려줍니다.
final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  final sample = SampleUploadRepository();
  if (!ref.watch(isApiEnabledProvider)) return sample;
  return ApiUploadRepository(
    client: ref.watch(apiClientProvider),
    // TODO: 카메라·앨범·파일 선택 플러그인을 붙이면 실제 파일을 고르도록 바꿉니다.
    // 예시 파일은 내용이 없어 서버에 올릴 수 없습니다.
    pick: sample.pick,
  );
});
