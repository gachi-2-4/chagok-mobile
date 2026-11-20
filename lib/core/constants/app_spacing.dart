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

  /// 상단 바 아래부터 화면의 첫 요소(큰 제목 등)까지 거리.
  static const pageTop = 11.0;

  /// 화면 안에서 제목·카드·배너·말풍선 같은 덩어리 사이 세로 간격.
  static const block = 18.0;

  /// 화면 맨 아래 버튼 묶음 아래 여백.
  static const actionsBottom = 24.0;

  /// 목록 끝에서 그 아래 주요 버튼까지 거리. 예: 채팅 목록의 "새 대화 시작"
  static const primaryActionTop = 44.0;

  /// 카드 제목과 그 아래 설명 사이 간격.
  static const cardTitleGap = 10.0;

  /// "오늘", "이전 대화" 같은 구역 이름 위 여백.
  static const eyebrowTop = 3.0;

  /// 내 질문 말풍선 왼쪽을 비워 두는 너비.
  static const chatBubbleIndent = 45.0;

  /// 홈처럼 상단 바 바로 아래 구역 제목이 오는 화면의 위 여백.
  static const pageTopCompact = 6.0;

  /// 구역 제목 줄과 그 아래 내용 사이 간격.
  static const sectionTitleGap = 10.0;

  /// 가로로 나란히 놓은 카드 사이 간격.
  static const cardGap = 10.0;

  /// 미니 캘린더에서 요일·날짜·일정 점 사이 간격.
  static const calendarDayGap = 6.0;

  /// "D-2" 같은 알약 모양 표 안쪽 좌우 여백.
  static const pillPaddingHorizontal = 9.0;

  /// 알약 모양 표와 옆 글자 사이 간격.
  static const pillGap = 10.0;

  /// 작은 표(예: 보관함의 "D-13") 안쪽 위아래 여백.
  static const tagPaddingVertical = 3.0;

  /// 최근 알림 카드 안쪽 위아래 여백.
  static const alertCardPaddingVertical = 6.0;

  /// 알림 제목과 그 아래 보관함·시각 사이 간격.
  static const alertMetaGap = 3.0;

  /// 보관함 상자 그림에서 몸통이 뚜껑보다 안쪽으로 들어간 너비.
  static const boxBodyInset = 9.0;

  /// 보관함 상자 그림에서 몸통이 시작하는 높이.
  static const boxBodyTop = 22.0;

  /// 보관함 상자 몸통 안쪽 왼쪽·위 여백.
  static const boxBodyPaddingStart = 14.0;

  /// 보관함 상자 몸통 안쪽 오른쪽·아래 여백.
  static const boxBodyPaddingEnd = 10.0;

  /// 보관함 상자 그림과 그 아래 이름 사이 간격.
  static const boxLabelGap = 10.0;

  /// 설정 화면 프로필 사진과 이름 사이 간격.
  static const avatarGap = 14.0;

  /// 그림이 왼쪽에 붙는 배너에서 배너 끝부터 그림까지 거리.
  static const bannerIllustrationInset = 14.0;

  /// 화면 제목 묶음(AppPageHeader)과 그 아래 내용 사이 간격.
  static const pageHeaderBottom = 24.0;

  /// 전화번호 인증처럼 내용 묶음 사이를 넓게 띄우는 화면의 간격.
  static const sectionGapLarge = 28.0;

  /// 간편 로그인 버튼의 회사 로고와 글자 사이 간격.
  static const socialLogoGap = 6.0;

  /// 이름·값 표에서 줄 사이 간격.
  static const tableRowGap = 10.0;

  /// 이름·값 표에서 구분선 위아래 여백.
  static const tableDividerGap = 14.0;

  /// 안내 카드에서 첫 문장과 도움말 사이 간격.
  static const noticeHelpGap = 9.0;

  /// 첫 설문 선택지 안쪽 좌우 여백.
  static const choicePaddingHorizontal = 17.0;

  /// 설문 진행 막대 칸 사이 간격.
  static const progressSegmentGap = 6.0;

  /// 알림 한 줄·상세 머리의 위아래 여백.
  static const noticePaddingVertical = 18.0;

  /// 알림 상세 본문의 안쪽 여백.
  static const noticeBodyPadding = 24.0;

  /// 알림 상세 본문의 정보 묶음 사이 간격.
  static const noticeBlockGap = 26.0;

  /// 보관함·서류를 두 줄로 늘어놓을 때 칸 사이 가로 간격.
  static const gridColumnGap = 16.0;

  /// 보관함·서류를 두 줄로 늘어놓을 때 줄 사이 세로 간격.
  static const gridRowGap = 22.0;

  /// 떠 있는 버튼(서류 올리기)에 마지막 줄이 가리지 않도록 목록 끝에 두는 여백.
  static const floatingButtonClearance = 88.0;

  /// 고른 색 칸의 바깥 테두리와 색 사이 간격.
  static const selectionRingGap = 3.0;

  /// 아래에서 올라오는 시트의 안쪽 위 여백(손잡이 위).
  static const sheetHandleTop = 10.0;
}
