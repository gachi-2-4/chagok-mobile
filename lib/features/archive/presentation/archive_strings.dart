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

  // 쉬운 말로 번역
  static const translate = '쉬운 말로 번역';
  static const plainLanguageTitle = '쉬운 말로 보기';
  static const translating = '쉬운 말로 바꾸고 있어요…';
  static const translateFailed = '쉬운 말로 바꾸지 못했어요.';
  static const aiNotice = 'AI가 바꾼 설명이라 원본과 다를 수 있어요. 중요한 내용은 원본을 확인해 주세요.';
  static const close = '닫기';

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
