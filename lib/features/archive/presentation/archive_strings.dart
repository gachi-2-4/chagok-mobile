import 'package:chagok_mobile/features/archive/data/box_color.dart';
import 'package:chagok_mobile/features/archive/data/box_icon.dart';
import 'package:chagok_mobile/features/archive/data/document_importance.dart';

/// 보관함 화면에 보이는 문구.
///
/// 다국어를 도입할 때 옮기기 쉽도록 한곳에 모읍니다.
abstract final class ArchiveStrings {
  static const title = '내 보관함';
  static const notifications = '알림';

  /// 읽지 않은 알림이 있을 때 종 버튼을 화면 읽기 프로그램이 읽는 이름.
  static const notificationsUnread = '알림, 읽지 않은 알림 있음';
  static const search = '서류 이름·내용 검색';
  static const loadFailed = '보관함을 불러오지 못했어요.';
  static const retry = '다시 시도';
  static const upload = '서류 올리기';

  static const newBox = '새 박스';

  /// 새 박스 칸의 예시. 칸이 좁아 뒤는 말줄임표로 줄여 보입니다.
  static const newBoxExamples = '집 · 차 · 세금 · 병원 · 무엇이든';

  // 새 박스 만들기 (05)
  static const newBoxTitle = '새 박스 만들기';
  static const boxNameHint = '박스 이름';
  static const colorLabel = '색';
  static const iconLabel = '아이콘';
  static const cancel = '취소';
  static const create = '만들기';
  static const createFailed = '박스를 만들지 못했어요. 다시 시도해 주세요.';

  // 서류 검색
  static const searchTitle = '서류 검색';
  static const searchGuide = '서류 이름이나 내용에 들어 있는 말로 찾아보세요.';
  static const searchFailed = '서류를 찾지 못했어요.';

  /// 예: "‘관리비’에 맞는 서류가 없어요."
  static String noSearchResult(String query) => '‘$query’에 맞는 서류가 없어요.';

  /// 서류 카드의 초록 버튼 이름.
  static const openSummary = 'AI 정리본 보기';

  // 서류 상세 (07~09)
  static const tabOriginal = '원본';
  static const tabSummary = 'AI 정리본';
  static const openSummaryAction = 'AI 정리본 열기';
  static const viewOriginal = '원본 보기';
  static const originalSampleNotice = '원본 이미지 준비 중 · 예시 화면';
  static const oneLineSummary = '한 줄 요약';
  static const importanceLabel = '중요도';
  static const costLabel = '비용';
  static const dDayLabel = 'D-day';
  static const deadlineRegistered = '기한 자동 등록됨';
  static const moreActions = '더보기';
  static const editContent = '내용 수정';
  static const paymentReminder = '납부일 알림';
  static const documentNotFound = '서류를 찾을 수 없어요.';
  static const documentLoadFailed = '서류를 불러오지 못했어요.';

  /// 원본 쪽 위치. 예: "1 / 4"
  static String pagePosition(int page, int total) => '$page / $total';

  /// 중요도 단계 이름. 예: "높음"
  static String importanceLevel(DocumentImportance importance) =>
      switch (importance) {
        DocumentImportance.high => '높음',
        DocumentImportance.medium => '보통',
        DocumentImportance.low => '낮음',
      };

  /// 예: "보증금 230,000,000원"
  static String cost(String label, int amount) => '$label ${_won(amount)}원';

  /// D-day 아래 기간·기한 한 줄. 예: "~2027.02.28 · 갱신 통보 12.28까지"
  static String dueLine({
    required DateTime dueDate,
    String? dueLabel,
    DateTime? periodEnd,
  }) {
    final due =
        '${dueLabel == null ? '' : '$dueLabel '}'
        '${dueDate.month}.${dueDate.day}까지';
    if (periodEnd == null) return due;
    return '~${periodEnd.year}.${_twoDigits(periodEnd.month)}.'
        '${_twoDigits(periodEnd.day)} · $due';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  /// 세 자리마다 쉼표를 넣습니다. 예: 230000000 → "230,000,000"
  static String _won(int amount) => amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  // 박스 상세 (06)
  static const boxNotFound = '보관함을 찾을 수 없어요.';
  static const emptyBox = '아직 담긴 서류가 없어요.';
  static const documentOriginal = '서류 원본';

  /// 예: "서류 3건"
  static String documentCount(int count) => '서류 $count건';

  /// 남은 날. 예: 13 → "D-13", 0 → "D-DAY"
  static String dDay(int days) => days == 0 ? 'D-DAY' : 'D-$days';

  /// 서류 원본 쪽수. 예: "4장"
  static String pageCount(int count) => '$count장';

  /// 예: "중요 높음"
  static String importance(DocumentImportance importance) =>
      switch (importance) {
        DocumentImportance.high => '중요 높음',
        DocumentImportance.medium => '중요 보통',
        DocumentImportance.low => '중요 낮음',
      };

  /// 색 고르기 칸을 화면 읽기 프로그램이 읽는 이름.
  static String colorName(BoxColor color) => switch (color) {
    BoxColor.peach => '살구색',
    BoxColor.green => '연두색',
    BoxColor.gray => '회색',
  };

  /// 아이콘 고르기 칸을 화면 읽기 프로그램이 읽는 이름.
  static String iconName(BoxIcon icon) => switch (icon) {
    BoxIcon.home => '집',
    BoxIcon.car => '자동차',
    BoxIcon.tax => '세금',
    BoxIcon.health => '건강',
    BoxIcon.telecom => '통신',
    BoxIcon.work => '일',
    BoxIcon.education => '교육',
    BoxIcon.pet => '반려동물',
    BoxIcon.travel => '여행',
    BoxIcon.life => '생활',
    BoxIcon.bank => '금융',
    BoxIcon.package => '기타',
  };
}
