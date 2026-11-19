import 'package:chagok_mobile/features/upload/application/upload_state.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 서류 올리기 상태. U01~U04 화면이 함께 쓰므로 화면을 벗어나도 유지합니다.
final uploadProvider = NotifierProvider<UploadNotifier, UploadState>(
  UploadNotifier.new,
);

/// 파일 고르기, 보관함 선택, 분석, 저장을 처리합니다.
class UploadNotifier extends Notifier<UploadState> {
  @override
  UploadState build() => const UploadState();

  UploadRepository get _repository => ref.read(uploadRepositoryProvider);

  /// [source]에서 파일을 고릅니다. 골랐으면 true, 취소했으면 false.
  ///
  /// 처음 고를 때 보관함 목록을 불러와 첫 보관함을 골라 둡니다.
  Future<bool> pick(UploadSource source) async {
    state = state.copyWith(isBusy: true);
    final document = await _repository.pick(source);
    if (document == null) {
      state = state.copyWith(isBusy: false);
      return false;
    }
    final boxes = state.boxes.isEmpty
        ? await _repository.fetchBoxes()
        : state.boxes;
    state = state.copyWith(
      document: document,
      boxes: boxes,
      selectedBoxId: state.selectedBoxId ?? boxes.firstOrNull?.id,
      result: () => null,
      isBusy: false,
    );
    return true;
  }

  void selectBox(String boxId) => state = state.copyWith(selectedBoxId: boxId);

  /// 고른 파일을 분석합니다. 분석할 수 없는 상태면 null.
  Future<AnalysisResult?> analyze() async {
    final document = state.document;
    if (document == null || !state.canAnalyze) return null;
    state = state.copyWith(isBusy: true);
    final result = await _repository.analyze(document);
    state = state.copyWith(result: () => result, isBusy: false);
    return result;
  }

  /// 분석 결과를 확인한 서류를 고른 보관함에 담습니다. 담았으면 true.
  Future<bool> save() async {
    final document = state.document;
    final result = state.result;
    final box = state.selectedBox;
    if (document == null ||
        result is! AnalysisSucceeded ||
        box == null ||
        state.isBusy) {
      return false;
    }
    state = state.copyWith(isBusy: true);
    await _repository.save(document: document, result: result, boxId: box.id);
    state = const UploadState();
    return true;
  }
}
