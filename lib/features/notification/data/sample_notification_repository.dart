import 'package:chagok_mobile/features/notification/data/app_notification.dart';
import 'package:chagok_mobile/features/notification/data/notification_kind.dart';
import 'package:chagok_mobile/features/notification/data/notification_repository.dart';

/// 백엔드가 정해지기 전까지 화면을 확인하려고 쓰는 예시 알림.
///
/// 날짜는 [fetchAll]의 now 기준으로 만들어, 언제 열어도 비슷하게 보입니다.
/// 읽음·완료 표시는 메모리에만 남습니다.
class SampleNotificationRepository implements NotificationRepository {
  final _read = <String>{'maintenance-paid', 'lease-expiry'};
  final _done = <String>{'maintenance-paid'};

  @override
  Future<List<AppNotification>> fetchAll(DateTime now) async {
    // 날짜는 달력 날짜로 셉니다. Duration으로 더하면 서머타임 경계에서 하루 어긋납니다.
    DateTime day(int offset, [int hour = 0]) =>
        DateTime(now.year, now.month, now.day + offset, hour);
    final rentDue = day(1);
    AppNotification mark(AppNotification notification) => notification.copyWith(
      isRead: _read.contains(notification.id),
      isDone: _done.contains(notification.id),
    );

    return [
      AppNotification(
        id: 'rent-due',
        kind: NotificationKind.payment,
        title: '내일은 월세 납부일이에요',
        sentAt: day(0, 9),
        boxName: '집 · 임대',
        dueDate: rentDue,
        amount: 500000,
        documentName: '임대차계약서',
        // 보관함 예시 서류와 같은 id라 서류 상세에서 열립니다.
        documentId: 'lease',
        message:
            '안녕하세요, 김차곡님.\n'
            '${rentDue.month}월 ${rentDue.day}일까지 월세 500,000원을 내면 돼요.\n'
            '납부일을 놓치지 않도록 하루 전에 알려드려요.',
      ),
      AppNotification(
        id: 'maintenance-paid',
        kind: NotificationKind.payment,
        title: '관리비 납부 완료',
        sentAt: day(-1),
        boxName: '집 · 임대',
        dueDate: day(-1),
        amount: 120000,
        message: '이번 달 관리비 120,000원을 냈다고 표시했어요.',
      ),
      AppNotification(
        id: 'lease-expiry',
        kind: NotificationKind.expiry,
        title: '임대차계약서 만기가 30일 남았어요',
        sentAt: day(-2),
        boxName: '집 · 임대',
        dueDate: day(28),
        documentName: '임대차계약서',
        // 보관함 예시 서류와 같은 id라 서류 상세에서 열립니다.
        documentId: 'lease',
        message: '계약을 이어 갈지 집주인과 미리 이야기해 두세요.',
      ),
    ].map(mark).toList();
  }

  @override
  Future<void> markRead(List<String> ids) async => _read.addAll(ids);

  @override
  Future<void> markDone(String id) async {
    _read.add(id);
    _done.add(id);
  }
}
