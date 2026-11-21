import 'package:chagok_mobile/features/notification/application/notification_filter.dart';
import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';

/// 알림 화면에 보이는 문구.
abstract final class NotificationStrings {
  static const title = '알림';
  static const settings = '알림 설정';
  static const markAllRead = '모두 읽음';
  static const loadFailed = '알림을 불러오지 못했어요.';
  static const retry = '다시 시도';
  static const saveFailed = '표시하지 못했어요. 다시 시도해 주세요.';
  static const notFound = '알림을 찾을 수 없어요.';
  static const unread = '읽지 않음';
  static const amount = '금액';
  static const linkedDocument = '연결 서류';
  static const guide = '안내';
  static const paymentGuide =
      '이미 납부했다면 완료로 표시해 주세요. 완료로 표시하면 알림 목록의 ‘완료’ 탭에서 다시 볼 수 있어요.';
  static const markDone = '납부 완료로 표시';
  static const markedDone = '완료로 표시했어요.';
  static const viewDocument = '연결된 서류 보기';

  /// 탭 이름.
  static String filter(NotificationFilter filter) => switch (filter) {
    NotificationFilter.all => '전체',
    NotificationFilter.unread => '읽지 않음',
    NotificationFilter.done => '완료',
  };

  /// 탭에 보일 알림이 없을 때 안내.
  static String empty(NotificationFilter filter) => switch (filter) {
    NotificationFilter.all => '받은 알림이 없어요.',
    NotificationFilter.unread => '읽지 않은 알림이 없어요.',
    NotificationFilter.done => '완료한 알림이 없어요.',
  };

  /// 읽지 않은 알림 수. 예: "새 알림 2개"
  static String newCount(int count) => '새 알림 $count개';

  /// 남은 날. 예: 1 → "D-1", 0 → "D-DAY"
  static String dDay(int days) => days == 0 ? 'D-DAY' : 'D-$days';

  /// 보낸 날짜. 0시가 아니면 시각을 붙입니다. 예: "2026-11-18 · 오전 9:00"
  static String sentAt(DateTime time) {
    final date =
        '${time.year}-${_twoDigits(time.month)}-${_twoDigits(time.day)}';
    final hasTime = time.hour != 0 || time.minute != 0;
    return hasTime ? '$date · ${_clock(time)}' : date;
  }

  /// 상세 머리 한 줄. 예: "2026-11-18 · 오전 9:00 · 집 · 임대"
  static String detailMeta(AppNotification notification) =>
      [sentAt(notification.sentAt), ?notification.boxName].join(' · ');

  /// 상세 제목. 종류 말머리를 붙입니다. 예: "[납부] 내일은 월세 납부일이에요"
  static String detailTitle(AppNotification notification) =>
      '[${_kind(notification.kind)}] ${notification.title}';

  /// 정보 묶음 제목. 예: "납부 정보"
  static String infoTitle(NotificationKind kind) =>
      '${_kind(kind)} ${kind == NotificationKind.payment ? '정보' : '일정'}';

  /// 날짜 칸 이름. 예: "납부일", "만기일"
  static String dueDateLabel(NotificationKind kind) => '${_kind(kind)}일';

  /// 금액. 예: 500000 → "500,000원"
  static String won(int amount) => '${_thousands(amount)}원';

  /// 긴 날짜. 예: "2026년 11월 25일"
  static String fullDate(DateTime date) =>
      '${date.year}년 ${date.month}월 ${date.day}일';

  /// 연결 서류 링크. 예: "임대차계약서 ›"
  static String documentLink(String name) => '$name ›';

  static String _kind(NotificationKind kind) => switch (kind) {
    NotificationKind.payment => '납부',
    NotificationKind.expiry => '만기',
    NotificationKind.notice => '안내',
  };

  static String _clock(DateTime time) {
    final period = time.hour < 12 ? '오전' : '오후';
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '$period $hour:${_twoDigits(time.minute)}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String _thousands(int value) => value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}
