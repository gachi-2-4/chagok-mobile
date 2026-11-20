import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';

/// 알림 테스트가 함께 쓰는 예시 알림. 기준 시각은 2026년 11월 18일입니다.
List<AppNotification> sampleNotifications() => [
  AppNotification(
    id: 'old',
    kind: NotificationKind.expiry,
    title: '임대차계약서 만기가 30일 남았어요',
    sentAt: DateTime(2026, 11, 16),
    isRead: true,
    boxName: '집 · 임대',
    documentName: '임대차계약서',
  ),
  AppNotification(
    id: 'rent',
    kind: NotificationKind.payment,
    title: '내일은 월세 납부일이에요',
    sentAt: DateTime(2026, 11, 18, 9),
    boxName: '집 · 임대',
    dueDate: DateTime(2026, 11, 19),
    amount: 500000,
    documentName: '임대차계약서',
    message: '안녕하세요, 김차곡님.\n11월 19일까지 월세 500,000원을 내면 돼요.',
  ),
  AppNotification(
    id: 'paid',
    kind: NotificationKind.payment,
    title: '관리비 납부 완료',
    sentAt: DateTime(2026, 11, 17),
    isRead: true,
    isDone: true,
  ),
];
