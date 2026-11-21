import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';

/// 올리려고 고른 파일 하나.
class PickedDocument {
  const PickedDocument({
    required this.fileName,
    required this.source,
    required this.pageCount,
    required this.preview,
    this.files = const [],
  });

  /// 예: "임대차계약서.pdf"
  final String fileName;

  /// 어디서 가져왔는지.
  final UploadSource source;

  /// 전체 페이지 수.
  final int pageCount;

  /// 첫 페이지를 글로 옮긴 미리 보기.
  final DocumentPreview preview;

  /// 서버에 올릴 파일. 사진은 찍거나 고른 순서대로 1~10장, PDF는 1개입니다.
  ///
  /// 기기의 카메라·앨범·파일 선택을 붙이기 전의 예시 파일은 비어 있습니다.
  final List<UploadFile> files;

  /// PDF 파일이면 true.
  bool get isPdf => source == UploadSource.pdf;
}
