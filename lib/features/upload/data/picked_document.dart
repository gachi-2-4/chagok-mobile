import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';

/// 올리려고 고른 파일 하나.
class PickedDocument {
  const PickedDocument({
    required this.fileName,
    required this.source,
    required this.pageCount,
    required this.preview,
  });

  /// 예: "임대차계약서.pdf"
  final String fileName;

  /// 어디서 가져왔는지.
  final UploadSource source;

  /// 전체 페이지 수.
  final int pageCount;

  /// 첫 페이지를 글로 옮긴 미리 보기.
  final DocumentPreview preview;

  /// PDF 파일이면 true.
  bool get isPdf => source == UploadSource.pdf;
}
