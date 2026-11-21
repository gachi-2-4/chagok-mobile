import 'package:chagok_mobile/features/upload/data/analysis_result.dart';
import 'package:chagok_mobile/features/upload/data/document_box.dart';
import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/extracted_field.dart';
import 'package:chagok_mobile/features/upload/data/picked_document.dart';
import 'package:chagok_mobile/features/upload/data/upload_repository.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';

/// 서버 없이 화면 흐름을 확인하려고 쓰는 저장소. 분석 결과는 늘 예시 임대차계약서입니다.
///
/// [pick]을 넘기면(앱 실행) 기기의 문서 스캐너·앨범·PDF로 실제 서류를 고르고,
/// 넘기지 않으면(테스트, 카메라 없는 시뮬레이터) 예시 서류를 바로 돌려줍니다.
/// 예시 서류로 카메라를 고르면 첫 분석에서 흐리다고 알려, 다시 찍기 흐름도 볼 수 있습니다.
class SampleUploadRepository implements UploadRepository {
  SampleUploadRepository({this._pick});

  /// 기기에서 서류를 고르는 함수. null이면 예시 서류를 돌려줍니다.
  final Future<PickedDocument?> Function(UploadSource source)? _pick;

  var _cameraAnalysisCount = 0;
  final savedFileNames = <String>[];

  static final _preview = DocumentPreview(
    title: '주택 임대차계약서',
    section: '제1조 보증금 및 월 임대료',
    lines: ['월 임대료　500,000원', '납부일　매월 25일'],
  );

  @override
  Future<PickedDocument?> pick(UploadSource source) async {
    if (_pick case final pick?) return pick(source);
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
    // 실제로 찍은 사진(파일이 있음)은 흐림 안내 없이 바로 결과를 보여 줍니다.
    if (document.files.isEmpty &&
        document.source == UploadSource.camera &&
        _cameraAnalysisCount++ == 0) {
      return const AnalysisUnclear();
    }
    return AnalysisSucceeded(
      // 서류 내용 수정(D01) 예시 서류와 같은 id라 "내용 수정"으로 열 수 있습니다.
      documentId: 'lease',
      documentType: '임대차계약서',
      pageCount: document.pageCount ?? 1,
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
