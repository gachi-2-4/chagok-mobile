import 'package:chagok_mobile/features/upload/data/document_preview.dart';
import 'package:chagok_mobile/features/upload/data/upload_file.dart';
import 'package:chagok_mobile/features/upload/data/upload_source.dart';

/// 올리려고 고른 파일 하나.
class PickedDocument {
  /// [files]는 복사해서 바꿀 수 없는 목록으로 보관합니다.
  /// 넘긴 목록을 나중에 고쳐도 올릴 파일은 바뀌지 않습니다.
  PickedDocument({
    required this.fileName,
    required this.source,
    this.pageCount,
    this.preview,
    List<UploadFile> files = const [],
  }) : files = List.unmodifiable(files);

  /// 예: "임대차계약서.pdf"
  final String fileName;

  /// 어디서 가져왔는지.
  final UploadSource source;

  /// 전체 페이지 수. PDF는 서버가 분석해야 알 수 있어 고른 때에는 null입니다.
  final int? pageCount;

  /// 첫 페이지를 글로 옮긴 미리 보기. 예시 서류에만 있고, 기기에서 가져온
  /// 서류는 null이며 화면은 첫 쪽 사진을 대신 보여 줍니다.
  final DocumentPreview? preview;

  /// 서버에 올릴 파일. 사진은 찍거나 고른 순서대로 1~10장, PDF는 1개입니다.
  ///
  /// 예시 저장소가 돌려주는 서류는 비어 있습니다. 바꿀 수 없습니다.
  final List<UploadFile> files;

  /// PDF 파일이면 true.
  bool get isPdf => source == UploadSource.pdf;
}
