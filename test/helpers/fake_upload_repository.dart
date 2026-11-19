import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/document_box.dart';
import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/extracted_field.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';

/// 정해 둔 결과를 돌려주고 저장 요청을 기록하는 가짜 [UploadRepository].
class FakeUploadRepository implements UploadRepository {
  bool isCancelled = false;
  AnalysisResult result = const AnalysisSucceeded(
    documentType: '임대차계약서',
    pageCount: 1,
    fields: [ExtractedField(label: '납부일', value: '매월 25일')],
  );
  int boxFetchCount = 0;

  /// 값을 넣으면 파일 고르기·분석·저장에서 이 예외를 던집니다.
  Exception? error;
  final saved = <String>[];

  @override
  Future<PickedDocument?> pick(UploadSource source) async {
    if (error case final error?) throw error;
    if (isCancelled) return null;
    return PickedDocument(
      fileName: '${source.name}.pdf',
      source: source,
      pageCount: 1,
      preview: const DocumentPreview(title: '제목', section: '조항', lines: []),
    );
  }

  @override
  Future<List<DocumentBox>> fetchBoxes() async {
    boxFetchCount++;
    return const [
      DocumentBox(id: 'housing', name: '집 · 임대'),
      DocumentBox(id: 'car', name: '자동차'),
    ];
  }

  @override
  Future<AnalysisResult> analyze(PickedDocument document) async {
    if (error case final error?) throw error;
    return result;
  }

  @override
  Future<void> save({
    required PickedDocument document,
    required AnalysisSucceeded result,
    required String boxId,
  }) async {
    if (error case final error?) throw error;
    saved.add('${document.fileName}@$boxId');
  }
}
