/// 차곡 디자인 시스템의 간격 토큰.
///
/// 여러 곳에서 쓰는 작은 간격은 단계 토큰([xxs]~[xl])을, 특정 컴포넌트에만
/// 쓰는 값은 컴포넌트 이름이 붙은 토큰을 씁니다.
abstract final class AppSpacing {
  /// 2. 제목과 바로 아래 보조 문구 사이처럼 아주 좁은 간격.
  static const xxs = 2.0;

  /// 4. 아이콘과 라벨, 큰 제목과 설명 사이 간격.
  static const xs = 4.0;

  /// 8. 한 줄 안에서 글자·값·아이콘 사이 간격.
  static const sm = 8.0;

  /// 12. 글머리표·라디오·체크박스와 문장 사이 간격.
  static const md = 12.0;

  /// 16. 목록 한 줄의 글자와 스위치 사이 간격.
  static const lg = 16.0;

  /// 20. 대화상자 안쪽 여백, 목록 한 줄의 오른쪽 여백.
  static const xl = 20.0;

  /// 화면 좌우 여백.
  static const screenHorizontal = 26.0;

  /// 알림 화면처럼 진한 제목을 쓰는 상단 바에서 화면 끝부터 아이콘까지 거리.
  static const plainTopBarIconInset = 24.0;

  /// 세로로 쌓이는 요소(입력창, 선택지 등) 사이 간격.
  static const stack = 12.0;

  /// 입력창 라벨과 입력창 사이 간격.
  static const fieldLabelGap = 9.0;

  /// 입력창 안쪽 좌우 여백. 오른쪽에 붙는 위젯(suffix)의 여백에도 씁니다.
  static const fieldPaddingHorizontal = 18.0;

  /// 입력창 안쪽 위아래 여백.
  static const fieldPaddingVertical = 16.0;

  /// 버튼이 여러 개일 때 버튼 사이 간격.
  static const buttonGap = 10.0;

  /// 카드 안쪽 여백.
  static const cardPadding = 18.0;

  /// 안내 띠 안쪽 좌우 여백.
  static const bannerPaddingHorizontal = 15.0;

  /// 안내 띠 안쪽 위아래 여백.
  static const bannerPaddingVertical = 11.0;

  /// 칩 안쪽 좌우 여백.
  static const chipPaddingHorizontal = 13.0;

  /// 스위치가 있는 목록 한 줄의 위아래 여백.
  static const toggleRowPaddingVertical = 14.0;

  /// 목록 구역 제목 위 여백.
  static const sectionHeaderTop = 18.0;

  /// 목록 구역 제목 아래 여백.
  static const sectionHeaderBottom = 6.0;

  /// 목록 구역 사이를 나누는 띠의 높이.
  static const sectionBandHeight = 8.0;

  /// 확인 대화상자 안쪽 위 여백. 나머지 세 방향은 [xl]입니다.
  static const dialogPaddingTop = 28.0;

  /// 하단 탭 바 좌우 여백.
  static const navBarPaddingHorizontal = 20.0;

  /// 하단 탭 바 위 여백. 탭을 누르는 영역에 포함됩니다.
  static const navBarPaddingTop = 10.0;

  /// 하단 탭 바 아래 여백. 탭을 누르는 영역에 포함됩니다.
  static const navBarPaddingBottom = 16.0;

  /// 화면 안에서 제목·카드·배너·말풍선 같은 덩어리 사이 세로 간격.
  static const block = 18.0;

  /// 화면 맨 아래 버튼 묶음 아래 여백.
  static const actionsBottom = 24.0;

  /// 화면 제목 묶음(AppPageHeader)과 그 아래 내용 사이 간격.
  static const pageHeaderBottom = 24.0;

  /// 첫 설문 선택지 안쪽 좌우 여백.
  static const choicePaddingHorizontal = 17.0;

  /// 설문 진행 막대 칸 사이 간격.
  static const progressSegmentGap = 6.0;
}
