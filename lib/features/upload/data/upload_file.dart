import 'dart:typed_data';

/// 서버에 올릴 파일 하나의 이름과 내용.
class UploadFile {
  const UploadFile({required this.fileName, required this.bytes});

  /// 확장자를 포함한 파일 이름. 서버는 확장자로 JPG·PNG·HEIC·PDF를 가립니다.
  final String fileName;

  /// 파일 내용.
  final Uint8List bytes;
}
