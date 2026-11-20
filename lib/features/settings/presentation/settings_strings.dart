import 'package:chagok_mobile/features/settings/data/text_size.dart';

/// 설정 화면에 보이는 문구.
///
/// 다국어를 도입할 때 옮기기 쉽도록 한곳에 모읍니다.
abstract final class SettingsStrings {
  static const brand = '차곡';
  static const comingSoon = '곧 지원할 예정이에요.';
  static const loadFailed = '설정을 불러오지 못했어요.';
  static const retry = '다시 시도';
  static const valueUnavailable = '불러오지 못함';
  static const profileLoadFailed = '내 정보를 불러오지 못했어요';

  // S01 설정
  static const title = '설정';
  static const appSection = '앱 설정';
  static const textSize = '글자 크기';
  static const notifications = '알림 설정';
  static const notificationsOn = '켜짐';
  static const notificationsOff = '꺼짐';
  static const infoSection = '정보';
  static const appVersion = '앱 버전';

  // TODO: 빌드 정보에서 읽어 오도록 바꿉니다.
  static const appVersionValue = 'v1.0.0';
  static const terms = '이용약관';
  static const privacyPolicy = '개인정보 처리방침';
  static const accountSection = '계정';
  static const logOut = '로그아웃';
  static const deleteAccount = '회원 탈퇴';

  // S04·S05 확인 창
  static const logOutConfirm = '로그아웃하시겠어요?';
  static const deleteAccountConfirm = '정말 탈퇴하시겠어요?';
  static const deleteAccountDescription = '탈퇴하면 보관한 서류와 기록이 모두 삭제되고 복구할 수 없어요.';
  static const deleteAccountAction = '탈퇴';
  static const logOutFailed = '로그아웃하지 못했어요. 다시 시도해 주세요.';
  static const deleteAccountFailed = '탈퇴하지 못했어요. 다시 시도해 주세요.';

  static String textSizeLabel(TextSize value) => switch (value) {
    TextSize.normal => '보통',
    TextSize.large => '크게',
    TextSize.extraLarge => '아주 크게',
  };

  // S02 글자 크기
  static const textSizeTitle = '글자 크기';
  static const textSizeDescription = '서류 설명을 편안하게 읽어 보세요.';
  static const previewSection = '미리 보기';
  static const previewText = '이번 달 관리비 안내\n11월 25일까지\n85,000원을 내면 돼요.';
  static const textSizeNote = '저장하면 차곡 앱 전체에 선택한 글자 크기가 적용돼요.';
  static const saveTextSize = '이 크기로 저장';
  static const textSizeSaved = '글자 크기를 바꿨어요.';
  static const textSizeSaveFailed = '글자 크기를 저장하지 못했어요. 다시 시도해 주세요.';

  // S03 알림 설정
  static const notificationTitle = '놓치지 않도록 알려 드려요';
  static const notificationDescription = '납부일 전에 미리 알려 드릴게요.';
  static const deviceNotificationQuestion = '알림이 오지 않는다면?';
  static const turnOnDeviceNotification = '기기 알림 켜기';
  static const receiveSection = '알림 받기';
  static const paymentReminder = '납부일 알림';
  static const paymentReminderDescription = '관리비·공과금 납부일 전에 미리 알려 드려요.';
  static const marketing = '마케팅 수신';
  static const marketingDescription = '이벤트와 새로운 소식을 받아 볼 수 있어요.';
  static const reminderTime = '기본 알림 시각';
  static const notificationNote = '기기 권한을 바꾸어도 등록한 납부 일정은 사라지지 않아요.';
  static const openDeviceSettings = '기기 설정 열기';
  static const later = '나중에 할게요';

  /// 알림 시각. 예: 540 → "오전 9시", 870 → "오후 2시 30분"
  static String reminderTimeLabel(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = switch (hour % 12) {
      0 => 12,
      final value => value,
    };
    return minute == 0
        ? '$period $displayHour시'
        : '$period $displayHour시 $minute분';
  }
}
