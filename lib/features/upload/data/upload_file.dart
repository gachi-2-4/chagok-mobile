import 'dart:typed_data';

/// 서버에 올릴 파일 하나의 이름과 내용.
class UploadFile {
  /// [bytes]는 복사해서 바꿀 수 없게 보관합니다. 넘긴 바이트를 나중에 고쳐도 올릴
  /// 내용은 바뀌지 않아, 토큰 재발급 뒤 다시 보낼 때도 같은 파일을 보냅니다.
  UploadFile({required this.fileName, required Uint8List bytes})
    : bytes = Uint8List.fromList(bytes).asUnmodifiableView();

  /// 확장자를 포함한 파일 이름. 서버는 확장자로 JPG·PNG·HEIC·PDF를 가립니다.
  final String fileName;

  /// 파일 내용. 바꿀 수 없습니다.
  final Uint8List bytes;
}
