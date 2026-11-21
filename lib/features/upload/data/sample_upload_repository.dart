import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/document_box.dart';
import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/extracted_field.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';

/// 플러그인과 분석 API가 정해지기 전까지 화면 흐름을 확인하려고 쓰는 저장소.
///
/// 어느 방법으로 골라도 같은 임대차계약서를 돌려줍니다. 카메라로 찍은
/// 사진은 첫 번째 분석에서 흐리다고 알려, 다시 찍기 흐름도 볼 수 있습니다.
class SampleUploadRepository implements UploadRepository {
  var _cameraAnalysisCount = 0;
  final savedFileNames = <String>[];

  static final _preview = DocumentPreview(
    title: '주택 임대차계약서',
    section: '제1조 보증금 및 월 임대료',
    lines: ['월 임대료　500,000원', '납부일　매월 25일'],
  );

  @override
  Future<PickedDocument?> pick(UploadSource source) async {
    return PickedDocument(
      fileName: switch (source) {
        UploadSource.camera => '촬영한 서류.jpg',
        UploadSource.album => '임대차계약서.jpg',
        UploadSource.pdf => '임대차계약서.pdf',
      },
      source: source,
      pageCount: source == UploadSource.pdf ? 3 : 1,
      preview: _preview,
    );
  }

  @override
  Future<List<DocumentBox>> fetchBoxes() async {
    return const [
      DocumentBox(id: 'housing', name: '집 · 임대'),
      DocumentBox(id: 'telecom', name: '통신 · 구독'),
      DocumentBox(id: 'car', name: '자동차'),
    ];
  }

  @override
  Future<AnalysisResult> analyze(
    PickedDocument document, {
    required String boxId,
  }) async {
    if (document.source == UploadSource.camera && _cameraAnalysisCount++ == 0) {
      return const AnalysisUnclear();
    }
    return AnalysisSucceeded(
      documentType: '임대차계약서',
      pageCount: document.pageCount,
      fields: const [
        ExtractedField(label: '월 임대료', value: '500,000원', originalLabel: '월세'),
        ExtractedField(label: '납부일', value: '매월 25일'),
        ExtractedField(label: '계약 종료일', value: '2027.1.2'),
        ExtractedField(label: '중도 해지 위약금'),
      ],
    );
  }

  @override
  Future<void> save({
    required PickedDocument document,
    required AnalysisSucceeded result,
    required String boxId,
  }) async {
    savedFileNames.add(document.fileName);
  }
}
