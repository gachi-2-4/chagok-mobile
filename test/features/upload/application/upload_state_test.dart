import 'package:chagok_mobile/features/upload/application/upload_state.dart';
import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/document_box.dart';
import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final document = PickedDocument(
    fileName: '임대차계약서.pdf',
    source: UploadSource.pdf,
    pageCount: 1,
    preview: DocumentPreview(title: '제목', section: '조항', lines: []),
  );
  const boxes = [DocumentBox(id: 'housing', name: '집 · 임대')];
  final succeeded = AnalysisSucceeded(
    documentType: '임대차계약서',
    pageCount: 1,
    fields: [],
  );

  group('UploadState', () {
    test('고른 보관함 id가 목록에 있으면 selectedBox가 그 보관함이다', () {
      const state = UploadState(boxes: boxes, selectedBoxId: 'housing');

      expect(state.selectedBox?.name, '집 · 임대');
    });

    test('파일과 보관함을 골랐으면 분석할 수 있다', () {
      final state = UploadState(
        document: document,
        boxes: boxes,
        selectedBoxId: 'housing',
      );

      expect(state.canAnalyze, isTrue);
    });

    test('분석에 성공했으면 보관할 수 있고 흐린 결과면 보관할 수 없다', () {
      final state = UploadState(
        document: document,
        boxes: boxes,
        selectedBoxId: 'housing',
        result: succeeded,
      );

      expect(state.canSave, isTrue);
      expect(
        state.copyWith(result: () => const AnalysisUnclear()).canSave,
        isFalse,
      );
    });

    test('다른 일을 하는 중이면 분석도 보관도 할 수 없다', () {
      final state = UploadState(
        document: document,
        boxes: boxes,
        selectedBoxId: 'housing',
        result: succeeded,
        isBusy: true,
      );

      expect(state.canAnalyze, isFalse);
      expect(state.canSave, isFalse);
    });

    test('copyWith에 null을 돌려주는 함수를 넘기면 분석 결과를 지운다', () {
      final state = UploadState(result: succeeded, hasFailed: true);

      final updated = state.copyWith(result: () => null);

      expect(updated.result, isNull);
      expect(updated.hasFailed, isTrue);
    });
  });
}
