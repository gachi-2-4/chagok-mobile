/// 카메라 권한이 꺼져 있어 서류를 찍을 수 없을 때 던지는 예외.
///
/// 다시 시도해도 같으므로, 화면은 기기 설정에서 권한을 켜 달라고 안내합니다.
class CameraPermissionDeniedException implements Exception {
  const CameraPermissionDeniedException();

  @override
  String toString() => 'CameraPermissionDeniedException';
}
