import 'dart:async';

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
  AnalysisResult result = AnalysisSucceeded(
    documentType: '임대차계약서',
    pageCount: 1,
    fields: const [ExtractedField(label: '납부일', value: '매월 25일')],
  );
  int boxFetchCount = 0;

  /// 값을 넣으면 파일 고르기·분석·저장에서 이 예외를 던집니다.
  Exception? error;

  /// 값을 넣으면 [pick]이 이것이 끝날 때까지 기다립니다.
  Completer<void>? pickGate;

  /// [pick]이 불린 횟수.
  int pickCount = 0;
  final saved = <String>[];

  /// [analyze]에 넘어온 보관함 id.
  final analyzedBoxIds = <String>[];

  @override
  Future<PickedDocument?> pick(UploadSource source) async {
    pickCount++;
    await pickGate?.future;
    if (error case final error?) throw error;
    if (isCancelled) return null;
    return PickedDocument(
      fileName: '${source.name}.pdf',
      source: source,
      pageCount: 1,
      preview: DocumentPreview(title: '제목', section: '조항', lines: []),
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
  Future<AnalysisResult> analyze(
    PickedDocument document, {
    required String boxId,
  }) async {
    if (error case final error?) throw error;
    analyzedBoxIds.add(boxId);
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
