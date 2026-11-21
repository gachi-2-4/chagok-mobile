/// 여러 기능이 함께 쓰는 공통 위젯·앱 틀의 문구.
///
/// 다국어를 도입할 때 옮기기 쉽도록 한곳에 모읍니다.
abstract final class CoreStrings {
  /// 앱 이름. 로고 자리와 앱 제목에 씁니다.
  static const appName = '차곡';

  /// 서류 화면 아래의 소개 문구.
  static const tagline = '차곡차곡, 쉬워지는 서류 생활';

  /// 확인 창의 확인 버튼.
  static const confirm = '예';

  /// 확인 창의 취소 버튼.
  static const cancel = '아니요';

  /// 상단 바의 더보기 버튼을 화면 읽기 프로그램이 읽는 이름.
  static const more = '더보기';

  /// 상단 바의 뒤로 가기 버튼을 화면 읽기 프로그램이 읽는 이름.
  static const back = '뒤로 가기';

  /// 서버에 닿지 못했을 때(네트워크 끊김·시간 초과) 보여 주는 안내.
  static const networkError = '인터넷 연결을 확인하고 다시 시도해 주세요.';

  /// 서버가 이유를 알려 주지 않은 오류의 안내.
  static const unknownError = '잠시 후 다시 시도해 주세요.';
}
