import 'package:chagok_mobile/core/network/api_client.dart';
import 'package:chagok_mobile/core/network/api_config.dart';
import 'package:chagok_mobile/core/network/session_notifier.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/api_upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/device_document_picker.dart';
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
/// 서류는 서버 유무와 관계없이 기기의 문서 스캐너·앨범·PDF 선택으로 고릅니다.
/// API 서버 주소가 있으면 서버에 올려 분석하고, 없으면 예시 분석 결과를 보여 줍니다.
///
/// 서버 없이도 기기에서 고르게 해, 서버가 없는 APK로도 스캐너를 확인할 수 있습니다.
/// 카메라가 없는 iOS 시뮬레이터에서는 사진 촬영이 실패 안내를 띄웁니다.
final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  final pick = DeviceDocumentPicker().pick;
  if (!ref.watch(isApiEnabledProvider)) {
    return SampleUploadRepository(pick: pick);
  }
  // 계정이 바뀌면 앞 계정의 데이터를 버리고 다시 불러오게 합니다.
  ref.watch(isSignedInProvider);
  return ApiUploadRepository(client: ref.watch(apiClientProvider), pick: pick);
});
